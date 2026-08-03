import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:qwe1/data/models/server_dto.dart';
import 'package:qwe1/data/models/metrics_dto.dart';
import 'package:qwe1/data/sources/remote/api_client.dart';
import 'package:qwe1/data/sources/remote/web_socket_client.dart';
import 'package:qwe1/data/sources/local/database.dart' as db;
import 'package:qwe1/data/sources/local/secure_storage.dart';
import 'package:qwe1/domain/entities/server.dart';
import 'package:qwe1/domain/entities/metrics.dart';
import 'package:qwe1/domain/repositories/server_repository.dart';

class ServerRepositoryImpl implements ServerRepository {
  ServerRepositoryImpl({
    required this.database,
    required this.secureStorage,
  });

  final db.AppDatabase database;
  final SecureStorage secureStorage;
  final _clients = <String, ApiClient>{};
  final _wsClients = <String, WebSocketClient>{};
  final _metricsControllers = <String, StreamController<HostMetrics>>{};

  @override
  Future<List<Server>> getServers() async {
    final rows = await database.getAllServers();
    // Restore authenticated API clients for any persisted servers.
    for (final row in rows) {
      await _ensureClient(row.id, row.agentUrl);
    }
    return rows.map<Server>((row) => Server(
      id: row.id,
      name: row.name,
      agentUrl: row.agentUrl,
      groupName: row.groupName,
      readOnly: row.readOnly,
      fingerprintHash: row.fingerprintHash,
      status: row.status,
      deviceId: row.deviceId,
      lastSeenAt: row.lastSeenAt,
      createdAt: row.createdAt,
      agentVersion: row.agentVersion,
      capabilities: Map<String, dynamic>.from(
        row.capsJson.isNotEmpty ? _decodeJson(row.capsJson) : {},
      ),
    )).toList();
  }

  @override
  Future<Server> getServer(String id) async {
    final row = await database.getServer(id);
    if (row == null) throw Exception('Server not found');
    return Server(
      id: row.id,
      name: row.name,
      agentUrl: row.agentUrl,
      groupName: row.groupName,
      readOnly: row.readOnly,
      fingerprintHash: row.fingerprintHash,
      status: row.status,
      deviceId: row.deviceId,
      lastSeenAt: row.lastSeenAt,
      createdAt: row.createdAt,
      agentVersion: row.agentVersion,
      capabilities: Map<String, dynamic>.from(
        row.capsJson.isNotEmpty ? _decodeJson(row.capsJson) : {},
      ),
    );
  }

  @override
  Future<Server> addServer({
    required String name,
    required String agentUrl,
    required String enrollmentToken,
    String groupName = '',
  }) async {
    final client = ApiClient(baseUrl: agentUrl);

    // Exchange enrollment token for credentials
    final response = await client.post('/auth/enroll', data: {
      'enrollmentToken': enrollmentToken,
      'device': {
        'name': name,
        'platform': 'flutter',
        'appVersion': '1.0.0',
      },
    });

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final serverFingerprint = data['serverFingerprint'] as String;

    // Get server status
    final statusResponse = await client.get('/status');
    final statusData = statusResponse.data as Map<String, dynamic>;

    final serverId = const Uuid().v4();
    final now = DateTime.now();

    // Save to database
    await database.insertServer(db.ServersCompanion.insert(
      id: serverId,
      name: name,
      agentUrl: agentUrl,
      createdAt: now,
    ));

    // Save tokens to secure storage
    await secureStorage.saveRefreshToken(serverId, refreshToken);
    await secureStorage.saveAccessToken(serverId, accessToken);
    await secureStorage.saveFingerprint(serverId, serverFingerprint);

    // Cache client (restore on refresh/startup via _ensureClient)
    _clients[serverId] = await _buildAuthenticatedClient(serverId, agentUrl);
    _clients[serverId]!.setAccessToken(accessToken);

    return getServer(serverId);
  }

  @override
  Future<Server> updateServer(Server server) async {
    await database.updateServer(db.ServersCompanion(
      id: Value(server.id),
      name: Value(server.name),
      agentUrl: Value(server.agentUrl),
    ));

    return getServer(server.id);
  }

  @override
  Future<void> deleteServer(String id) async {
    await database.deleteServer(id);
    await secureStorage.deleteAllServerData(id);
    _clients.remove(id);
    _wsClients.remove(id);
    _metricsControllers.remove(id);
  }

  @override
  Future<void> testConnection(String agentUrl) async {
    final client = ApiClient(baseUrl: agentUrl);
    await client.get('/status');
  }

  @override
  Future<ServerStatus> getStatus(String agentUrl) async {
    final client = ApiClient(baseUrl: agentUrl);
    final response = await client.get('/status');
    final data = response.data as Map<String, dynamic>;

    return ServerStatus(
      name: data['name'] as String,
      agentVersion: data['agentVersion'] as String,
      apiVersion: data['apiVersion'] as int,
      capabilities: Map<String, bool>.from(data['caps'] as Map),
    );
  }

  @override
  Future<HostMetrics> getLatestMetrics(String serverId) async {
    final client = _getAuthenticatedClient(serverId);
    final response = await client.get('/metrics/latest');
    final data = response.data as Map<String, dynamic>;
    final dto = MetricsDto.fromJson(data);
    return dto.toEntity();
  }

  @override
  Future<List<HostMetrics>> getMetricsHistory(
    String serverId, {
    String range = '1h',
    String resolution = '1m',
  }) async {
    final client = _getAuthenticatedClient(serverId);
    final response = await client.get('/metrics/history', queryParameters: {
      'range': range,
      'resolution': resolution,
    });
    final data = response.data as List;
    return data
        .map((e) => MetricsDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Stream<HostMetrics> watchMetrics(String serverId) {
    if (_metricsControllers.containsKey(serverId)) {
      return _metricsControllers[serverId]!.stream;
    }

    final controller = StreamController<HostMetrics>.broadcast();
    _metricsControllers[serverId] = controller;

    _connectWebSocket(serverId, ['metrics']).then((_) {
      final wsClient = _wsClients[serverId];
      if (wsClient != null) {
        wsClient.subscribe('metrics').listen(
          (data) {
            if (data is Map<String, dynamic>) {
              final dto = MetricsDto.fromJson(data);
              controller.add(dto.toEntity());
            }
          },
          onError: controller.addError,
        );
      }
    });

    return controller.stream;
  }

  ApiClient _getAuthenticatedClient(String serverId) {
    final client = _clients[serverId];
    if (client == null) throw Exception('Server not connected');
    return client;
  }

  @override
  ApiClient getClient(String serverId) {
    return _getAuthenticatedClient(serverId);
  }

  @override
  Future<String?> getAccessToken(String serverId) async {
    return secureStorage.getAccessToken(serverId);
  }

  /// Builds an ApiClient wired to refresh its access token via /auth/refresh.
  Future<ApiClient> _buildAuthenticatedClient(String serverId, String agentUrl) async {
    final client = ApiClient(
      baseUrl: agentUrl,
      onRefreshToken: () => _refreshAccessToken(serverId),
    );
    final stored = await secureStorage.getAccessToken(serverId);
    if (stored != null) {
      client.setAccessToken(stored);
    }
    return client;
  }

  /// Rebuilds the in-memory authenticated client for a persisted server so
  /// requests carry a valid Authorization header after an app restart.
  Future<void> _ensureClient(String serverId, String agentUrl) async {
    if (_clients.containsKey(serverId)) return;
    final token = await secureStorage.getAccessToken(serverId);
    if (token == null) return;
    _clients[serverId] =
        await _buildAuthenticatedClient(serverId, agentUrl);
  }

  /// Exchanges the stored refresh token for a fresh access token. The server
  /// returns both, so the refresh token is rotated and re-persisted as well.
  Future<String?> _refreshAccessToken(String serverId) async {
    final refreshToken = await secureStorage.getRefreshToken(serverId);
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('[server] no refresh token stored for $serverId');
      return null;
    }
    try {
      final server = await getServer(serverId);
      final client = ApiClient(baseUrl: server.agentUrl);
      final response = await client.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      await secureStorage.saveAccessToken(serverId, accessToken);
      await secureStorage.saveRefreshToken(serverId, newRefreshToken);

      await _ensureClient(serverId, server.agentUrl);
      _clients[serverId]?.setAccessToken(accessToken);

      return accessToken;
    } catch (e) {
      debugPrint('[server] token refresh failed for $serverId: $e');
      return null;
    }
  }

  Future<void> _connectWebSocket(String serverId, List<String> channels) async {
    final server = await getServer(serverId);
    final token = await secureStorage.getAccessToken(serverId);
    if (token == null) throw Exception('Not authenticated');

    final wsClient = WebSocketClient(baseUrl: server.agentUrl);
    await wsClient.connect(token: token, channels: channels);
    _wsClients[serverId] = wsClient;
  }

  String _encodeJson(Map<String, dynamic> json) {
    return jsonEncode(json);
  }

  Map<String, dynamic> _decodeJson(String json) {
    if (json.isEmpty || json == '{}') return {};
    return Map<String, dynamic>.from(jsonDecode(json) as Map);
  }
}
