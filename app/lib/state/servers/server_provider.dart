import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/server.dart';
import 'package:qwe1/domain/entities/metrics.dart';
import 'package:qwe1/domain/repositories/server_repository.dart';

// Server list provider
final serverListProvider = StateNotifierProvider<ServerListNotifier, AsyncValue<List<Server>>>((ref) {
  return ServerListNotifier(ref);
});

class ServerListNotifier extends StateNotifier<AsyncValue<List<Server>>> {
  ServerListNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadServers();
  }

  final Ref ref;

  Future<void> loadServers() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(serverRepositoryProvider);
      final servers = await repository.getServers();
      state = AsyncValue.data(servers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addServer({
    required String name,
    required String agentUrl,
    required String enrollmentToken,
    String groupName = '',
  }) async {
    try {
      final repository = ref.read(serverRepositoryProvider);
      await repository.addServer(
        name: name,
        agentUrl: agentUrl,
        enrollmentToken: enrollmentToken,
        groupName: groupName,
      );
      await loadServers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateServer(Server server) async {
    try {
      final repository = ref.read(serverRepositoryProvider);
      await repository.updateServer(server);
      await loadServers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteServer(String id) async {
    try {
      final repository = ref.read(serverRepositoryProvider);
      await repository.deleteServer(id);
      await loadServers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Single server provider
final serverProvider = FutureProvider.family<Server, String>((ref, serverId) async {
  final repository = ref.watch(serverRepositoryProvider);
  return repository.getServer(serverId);
});

// Server metrics provider
final serverMetricsProvider = StreamProvider.family<HostMetrics, String>((ref, serverId) {
  final repository = ref.watch(serverRepositoryProvider);
  return repository.watchMetrics(serverId);
});

// Server status provider (for connectivity check)
final serverStatusProvider = FutureProvider.family<ServerStatus, String>((ref, agentUrl) async {
  final repository = ref.watch(serverRepositoryProvider);
  return repository.getStatus(agentUrl);
});

// Theme mode provider - moved to settings_provider.dart

// Server repository provider (placeholder - would be injected via DI)
final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  throw UnimplementedError('Server repository not initialized');
});
