import 'dart:async';
import 'dart:typed_data';

import 'package:qwe1/data/sources/remote/api_client.dart';
import 'package:qwe1/domain/entities/alert.dart';
import 'package:qwe1/domain/entities/container.dart';
import 'package:qwe1/domain/entities/file_item.dart';
import 'package:qwe1/domain/entities/metrics.dart';
import 'package:qwe1/domain/entities/server.dart';
import 'package:qwe1/domain/entities/terminal.dart';
import 'package:qwe1/domain/repositories/alert_repository.dart';
import 'package:qwe1/domain/repositories/docker_repository.dart';
import 'package:qwe1/domain/repositories/file_repository.dart';
import 'package:qwe1/domain/repositories/server_repository.dart';
import 'package:qwe1/domain/repositories/terminal_repository.dart';
import 'package:qwe1/data/sources/local/secure_storage.dart';
import 'package:qwe1/domain/repositories/auth_repository.dart';

class FakeSecureStorage extends SecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> saveThemeMode(String mode) async => _store['theme_mode'] = mode;

  @override
  Future<String?> getThemeMode() async => _store['theme_mode'];

  @override
  Future<void> saveBiometricEnabled(bool enabled) async =>
      _store['biometric_enabled'] = enabled.toString();

  @override
  Future<bool> getBiometricEnabled() async =>
      _store['biometric_enabled'] == 'true';
}

class FakeServerRepository implements ServerRepository {
  final List<Server> _servers = [];

  @override
  Future<List<Server>> getServers() async => List.of(_servers);

  @override
  Future<Server> getServer(String id) async {
    return _servers.firstWhere((s) => s.id == id);
  }

  @override
  Future<Server> addServer({
    required String name,
    required String agentUrl,
    required String enrollmentToken,
    String groupName = '',
  }) async {
    final server = Server(
      id: 'server-${_servers.length + 1}',
      name: name,
      agentUrl: agentUrl,
      groupName: groupName,
      createdAt: DateTime.now(),
      status: 'online',
    );
    _servers.add(server);
    return server;
  }

  @override
  Future<Server> updateServer(Server server) async {
    final i = _servers.indexWhere((s) => s.id == server.id);
    if (i >= 0) _servers[i] = server;
    return server;
  }

  @override
  Future<void> deleteServer(String id) async {
    _servers.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> testConnection(String agentUrl) async {}

  @override
  Future<ServerStatus> getStatus(String agentUrl) async {
    return ServerStatus(
      name: 'test',
      agentVersion: '1.0.0',
      apiVersion: 1,
      capabilities: const {},
    );
  }

  @override
  Future<HostMetrics> getLatestMetrics(String serverId) async =>
      _sampleMetrics();

  @override
  Future<List<HostMetrics>> getMetricsHistory(
    String serverId, {
    String range = '1h',
    String resolution = '1m',
  }) async =>
      [_sampleMetrics()];

  @override
  Stream<HostMetrics> watchMetrics(String serverId) =>
      Stream.value(_sampleMetrics());

  @override
  ApiClient getClient(String serverId) => ApiClient(baseUrl: 'http://localhost');

  @override
  Future<String?> getAccessToken(String serverId) async => null;

  HostMetrics _sampleMetrics() {
    return HostMetrics(
      timestamp: DateTime.now(),
      host: HostInfo(
        hostname: 'test',
        uptimeSeconds: 100,
        load: [0.1],
        cpu: const CpuMetrics(percent: 10.0, perCore: [10.0]),
        memory: const MemoryMetrics(total: 1000000, used: 500000, percent: 50.0),
        disk: [const DiskMetrics(mount: '/', total: 100, used: 50, percent: 50.0)],
        network: const NetworkMetrics(),
        sensors: [],
      ),
    );
  }
}

class FakeDockerRepository implements DockerRepository {
  @override
  Future<List<Container>> getContainers(String serverId, {String? filter}) async => [];

  @override
  Future<Container> getContainer(String serverId, String containerId) async =>
      throw StateError('not found');

  @override
  Future<ContainerInspect> inspectContainer(String serverId, String containerId) async =>
      throw StateError('not found');

  @override
  Future<void> startContainer(String serverId, String containerId) async {}

  @override
  Future<void> stopContainer(String serverId, String containerId) async {}

  @override
  Future<void> restartContainer(String serverId, String containerId) async {}

  @override
  Future<void> pauseContainer(String serverId, String containerId) async {}

  @override
  Future<void> unpauseContainer(String serverId, String containerId) async {}

  @override
  Future<void> killContainer(String serverId, String containerId, {String? signal}) async {}

  @override
  Future<void> removeContainer(String serverId, String containerId, {bool force = false}) async {}

  @override
  Future<List<String>> getContainerLogs(String serverId, String containerId, {int tail = 200}) async => [];

  @override
  Stream<String> streamContainerLogs(String serverId, String containerId) => const Stream.empty();

  @override
  Stream<ContainerEvent> watchContainerEvents(String serverId) => const Stream.empty();
}

class FakeTerminalRepository implements TerminalRepository {
  @override
  Future<TerminalSession> createSession(String serverId, {int cols = 80, int rows = 24}) async =>
      TerminalSession(sessionId: 'sess', serverId: serverId);

  @override
  Future<void> deleteSession(String serverId, String sessionId) async {}

  @override
  Future<List<TerminalSession>> getSessions(String serverId) async => [];

  @override
  Stream<Uint8List> getOutputStream(String serverId, String sessionId) => const Stream.empty();

  @override
  void sendInput(String serverId, String sessionId, Uint8List data) {}

  @override
  void resize(String serverId, String sessionId, int cols, int rows) {}
}

class FakeFileRepository implements FileRepository {
  @override
  Future<List<FileItem>> listFiles(String serverId, String path, {bool hidden = false}) async => [];

  @override
  Future<Uint8List> readFile(String serverId, String path, {int? maxBytes}) async => Uint8List(0);

  @override
  Future<void> writeFile(String serverId, String path, Uint8List data) async {}

  @override
  Future<void> createDirectory(String serverId, String path) async {}

  @override
  Future<void> rename(String serverId, String from, String to) async {}

  @override
  Future<void> delete(String serverId, String path, {bool recursive = false}) async {}

  @override
  Future<void> upload(String serverId, String path, String name, Uint8List data) async {}
}

class FakeAlertRepository implements AlertRepository {
  @override
  Future<List<Alert>> getAlerts(String serverId, {AlertSeverity? severity, DateTime? since}) async => [];

  @override
  Future<void> acknowledgeAlert(String serverId, String alertId) async {}

  @override
  Future<AlertThreshold> getThresholds(String serverId) async => const AlertThreshold();

  @override
  Future<void> updateThresholds(String serverId, AlertThreshold thresholds) async {}

  @override
  Stream<Alert> watchAlerts(String serverId) => const Stream.empty();
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> enroll({
    required String agentUrl,
    required String enrollmentToken,
    required String deviceName,
  }) async =>
      AuthResult(
        accessToken: 'access',
        refreshToken: 'refresh',
        expiresIn: 900,
        refreshExpiresIn: 2592000,
        serverFingerprint: 'fp',
      );

  @override
  Future<AuthResult> refresh(String refreshToken) async => throw UnimplementedError();

  @override
  Future<void> revoke(String serverId) async {}

  @override
  Future<DeviceInfo> getDeviceInfo(String serverId) async =>
      DeviceInfo(
        deviceId: 'dev',
        serverName: 'test',
        agentVersion: '1.0.0',
        capabilities: const {},
        readOnly: false,
      );
}