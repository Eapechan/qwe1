import 'dart:async';

import 'package:flutter/foundation.dart';
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
    _startStatusTimer();
  }

  final Ref ref;
  Timer? _statusTimer;

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshStatuses();
    });
  }

  Future<void> loadServers() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(serverRepositoryProvider);
      final servers = await repository.getServers();
      state = AsyncValue.data(servers);
      // Fire-and-forget status check; results update state directly.
      refreshStatuses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Pings /status for every server and persists the result so the
  /// dashboard shows the correct green/grey indicator.
  Future<void> refreshStatuses() async {
    final currentServers = state.valueOrNull;
    if (currentServers == null || currentServers.isEmpty) return;

    final repository = ref.read(serverRepositoryProvider);
    final futures = <Future<Server>>[];
    for (final server in currentServers) {
      futures.add(_pingStatus(server));
    }
    final updated = await Future.wait(futures);

    bool changed = false;
    final newServers = <Server>[];
    for (final server in updated) {
      final original = currentServers.firstWhere((s) => s.id == server.id);
      if (server.status != original.status ||
          !_sameCapabilities(server.capabilities, original.capabilities)) {
        changed = true;
        // Persist status/capability change. Call repository directly (not the
        // notifier's updateServer) to avoid triggering loadServers recursively.
        repository.updateServer(server);
      }
      newServers.add(server);
    }
    if (changed) {
      state = AsyncValue.data(newServers);
    }
  }

  static bool _sameCapabilities(Map<String, dynamic> a, Map<String, dynamic> b) {
    final keys = {...a.keys, ...b.keys};
    for (final k in keys) {
      if (a[k] != b[k]) return false;
    }
    return true;
  }

  Future<Server> _pingStatus(Server server) async {
    try {
      final repository = ref.read(serverRepositoryProvider);
      final status = await repository.getStatus(server.agentUrl);
      return server.copyWith(
        status: 'online',
        capabilities: status.capabilities,
      );
    } catch (e) {
      debugPrint('[status] ping failed for ${server.name} (${server.agentUrl}): $e');
      return server.copyWith(status: 'offline');
    }
  }

  Future<void> addServer({
    required String name,
    required String agentUrl,
    required String enrollmentToken,
    String tailscaleUrl = '',
    String groupName = '',
  }) async {
    try {
      final repository = ref.read(serverRepositoryProvider);
      final server = await repository.addServer(
        name: name,
        agentUrl: agentUrl,
        enrollmentToken: enrollmentToken,
        tailscaleUrl: tailscaleUrl,
        groupName: groupName,
      );
      // Mark the server as online immediately — we just successfully
      // enrolled, so it is reachable.
      await repository.updateServer(server.copyWith(status: 'online'));
      await loadServers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
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
