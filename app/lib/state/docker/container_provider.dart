import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/container.dart';
import 'package:qwe1/domain/repositories/docker_repository.dart';

// Container list provider
final containerListProvider = StateNotifierProvider.family<ContainerListNotifier, AsyncValue<List<Container>>, String>((ref, serverId) {
  return ContainerListNotifier(ref, serverId);
});

class ContainerListNotifier extends StateNotifier<AsyncValue<List<Container>>> {
  ContainerListNotifier(this.ref, this.serverId) : super(const AsyncValue.loading()) {
    loadContainers();
  }

  final Ref ref;
  final String serverId;

  Future<void> loadContainers() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(dockerRepositoryProvider);
      final containers = await repository.getContainers(serverId);
      state = AsyncValue.data(containers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startContainer(String containerId) async {
    try {
      final repository = ref.read(dockerRepositoryProvider);
      await repository.startContainer(serverId, containerId);
      await loadContainers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> stopContainer(String containerId) async {
    try {
      final repository = ref.read(dockerRepositoryProvider);
      await repository.stopContainer(serverId, containerId);
      await loadContainers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restartContainer(String containerId) async {
    try {
      final repository = ref.read(dockerRepositoryProvider);
      await repository.restartContainer(serverId, containerId);
      await loadContainers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pauseContainer(String containerId) async {
    try {
      final repository = ref.read(dockerRepositoryProvider);
      await repository.pauseContainer(serverId, containerId);
      await loadContainers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unpauseContainer(String containerId) async {
    try {
      final repository = ref.read(dockerRepositoryProvider);
      await repository.unpauseContainer(serverId, containerId);
      await loadContainers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> killContainer(String containerId, {String? signal}) async {
    try {
      final repository = ref.read(dockerRepositoryProvider);
      await repository.killContainer(serverId, containerId, signal: signal);
      await loadContainers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeContainer(String containerId) async {
    try {
      final repository = ref.read(dockerRepositoryProvider);
      await repository.removeContainer(serverId, containerId, force: true);
      await loadContainers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Single container provider
final containerProvider = FutureProvider.family<Container, ({String serverId, String containerId})>((ref, params) async {
  final repository = ref.watch(dockerRepositoryProvider);
  return repository.getContainer(params.serverId, params.containerId);
});

// Container inspect provider
final containerInspectProvider = FutureProvider.family<ContainerInspect, ({String serverId, String containerId})>((ref, params) async {
  final repository = ref.watch(dockerRepositoryProvider);
  return repository.inspectContainer(params.serverId, params.containerId);
});

// Container logs provider
final containerLogsProvider = StreamProvider.family<String, ({String serverId, String containerId})>((ref, params) {
  final repository = ref.watch(dockerRepositoryProvider);
  return repository.streamContainerLogs(params.serverId, params.containerId);
});

// Docker repository provider (placeholder)
final dockerRepositoryProvider = Provider<DockerRepository>((ref) {
  throw UnimplementedError('Docker repository not initialized');
});
