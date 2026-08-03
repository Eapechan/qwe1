import 'package:qwe1/data/sources/remote/api_client.dart';
import 'package:qwe1/domain/entities/server.dart';
import 'package:qwe1/domain/entities/metrics.dart';

abstract class ServerRepository {
  Future<List<Server>> getServers();
  Future<Server> getServer(String id);
  Future<Server> addServer({
    required String name,
    required String agentUrl,
    required String enrollmentToken,
    String tailscaleUrl,
    String groupName,
  });
  Future<Server> updateServer(Server server);
  Future<void> deleteServer(String id);
  Future<void> testConnection(String agentUrl);
  Future<ServerStatus> getStatus(String agentUrl);
  Future<HostMetrics> getLatestMetrics(String serverId);
  Future<List<HostMetrics>> getMetricsHistory(
    String serverId, {
    String range = '1h',
    String resolution = '1m',
  });
  Stream<HostMetrics> watchMetrics(String serverId);
  ApiClient getClient(String serverId);
  Future<String?> getAccessToken(String serverId);
}

class ServerStatus {
  final String name;
  final String agentVersion;
  final int apiVersion;
  final Map<String, bool> capabilities;

  ServerStatus({
    required this.name,
    required this.agentVersion,
    required this.apiVersion,
    required this.capabilities,
  });
}
