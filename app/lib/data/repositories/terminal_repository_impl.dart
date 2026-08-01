import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:qwe1/data/sources/remote/web_socket_client.dart';
import 'package:qwe1/domain/entities/terminal.dart';
import 'package:qwe1/domain/repositories/server_repository.dart';
import 'package:qwe1/domain/repositories/terminal_repository.dart';

class TerminalRepositoryImpl implements TerminalRepository {
  TerminalRepositoryImpl({required this.serverRepository});

  final ServerRepository serverRepository;
  final _wsClients = <String, WebSocketClient>{};
  final _outputControllers = <String, StreamController<Uint8List>>{};

  @override
  Future<TerminalSession> createSession(String serverId, {int cols = 80, int rows = 24}) async {
    final client = serverRepository.getClient(serverId);
    final response = await client.post('/terminal', data: {
      'cols': cols,
      'rows': rows,
    });

    final data = response.data as Map<String, dynamic>;
    final sessionId = data['sessionId'] as String;

    return TerminalSession(
      sessionId: sessionId,
      serverId: serverId,
      title: 'Terminal $sessionId',
      isActive: true,
      lastActiveAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteSession(String serverId, String sessionId) async {
    final client = serverRepository.getClient(serverId);
    await client.delete('/terminal/$sessionId');
  }

  @override
  Future<List<TerminalSession>> getSessions(String serverId) async {
    return [];
  }

  @override
  Stream<Uint8List> getOutputStream(String serverId, String sessionId) {
    final key = '$serverId:$sessionId';

    if (_outputControllers.containsKey(key)) {
      return _outputControllers[key]!.stream;
    }

    final controller = StreamController<Uint8List>.broadcast();
    _outputControllers[key] = controller;

    _connectTerminalWebSocket(serverId, sessionId, controller);

    return controller.stream;
  }

  @override
  void sendInput(String serverId, String sessionId, Uint8List data) {
    final key = '$serverId:$sessionId';
    final wsClient = _wsClients[key];
    if (wsClient != null) {
      wsClient.sendJson({'op': 'input', 'data': base64Encode(data)});
    }
  }

  @override
  void resize(String serverId, String sessionId, int cols, int rows) {
    final key = '$serverId:$sessionId';
    final wsClient = _wsClients[key];
    if (wsClient != null) {
      wsClient.sendJson({'op': 'resize', 'cols': cols, 'rows': rows});
    }
  }

  Future<void> _connectTerminalWebSocket(
    String serverId,
    String sessionId,
    StreamController<Uint8List> controller,
  ) async {
    try {
      final server = await serverRepository.getServer(serverId);
      final token = await serverRepository.getAccessToken(serverId) ?? '';
      final wsClient = WebSocketClient(baseUrl: server.agentUrl);
      await wsClient.connect(token: token, channels: ['terminal:$sessionId']);
      _wsClients['$serverId:$sessionId'] = wsClient;

      wsClient.subscribe('terminal:$sessionId').listen(
        (data) {
          if (data is Map<String, dynamic> && data['data'] != null) {
            final decoded = base64Decode(data['data'] as String);
            controller.add(decoded);
          }
        },
        onError: controller.addError,
      );
    } catch (e) {
      controller.addError(e);
    }
  }
}
