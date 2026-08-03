import 'dart:async';

import 'package:qwe1/data/models/container_dto.dart';
import 'package:qwe1/data/sources/remote/api_client.dart';
import 'package:qwe1/domain/entities/container.dart';
import 'package:qwe1/domain/repositories/docker_repository.dart';
import 'package:qwe1/domain/repositories/server_repository.dart';

class DockerRepositoryImpl implements DockerRepository {
  DockerRepositoryImpl({
    required this.serverRepository,
  });

  final ServerRepository serverRepository;
  final _eventControllers = <String, StreamController<ContainerEvent>>{};
  final _logControllers = <String, StreamController<String>>{};

  @override
  Future<List<Container>> getContainers(String serverId, {String? filter}) async {
    final client = _getClient(serverId);
    final response = await client.get('/docker/containers', queryParameters: {
      if (filter != null) 'filters': filter,
    });

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List;

    return items
        .map((e) => ContainerDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<Container> getContainer(String serverId, String containerId) async {
    final containers = await getContainers(serverId);
    return containers.firstWhere((c) => c.id == containerId);
  }

  @override
  Future<ContainerInspect> inspectContainer(String serverId, String containerId) async {
    final client = _getClient(serverId);
    final response = await client.get('/docker/containers/$containerId/inspect');
    final data = response.data as Map<String, dynamic>;
    final dto = ContainerInspectDto.fromJson(data);
    return dto.toEntity();
  }

  @override
  Future<void> startContainer(String serverId, String containerId) async {
    final client = _getClient(serverId);
    await client.post('/docker/containers/$containerId/start');
  }

  @override
  Future<void> stopContainer(String serverId, String containerId) async {
    final client = _getClient(serverId);
    await client.post('/docker/containers/$containerId/stop');
  }

  @override
  Future<void> restartContainer(String serverId, String containerId) async {
    final client = _getClient(serverId);
    await client.post('/docker/containers/$containerId/restart');
  }

  @override
  Future<void> pauseContainer(String serverId, String containerId) async {
    final client = _getClient(serverId);
    await client.post('/docker/containers/$containerId/pause');
  }

  @override
  Future<void> unpauseContainer(String serverId, String containerId) async {
    final client = _getClient(serverId);
    await client.post('/docker/containers/$containerId/unpause');
  }

  @override
  Future<void> killContainer(String serverId, String containerId, {String? signal}) async {
    final client = _getClient(serverId);
    await client.post('/docker/containers/$containerId/kill', data: {
      if (signal != null) 'signal': signal,
    });
  }

  @override
  Future<void> removeContainer(String serverId, String containerId, {bool force = false}) async {
    final client = _getClient(serverId);
    await client.delete('/docker/containers/$containerId', queryParameters: {
      'force': force,
      'v': true,
    });
  }

  @override
  Future<List<String>> getContainerLogs(String serverId, String containerId, {int tail = 200}) async {
    final client = _getClient(serverId);
    final response = await client.get('/docker/containers/$containerId/logs', queryParameters: {
      'tail': tail,
      'follow': false,
    });

    final data = response.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Stream<String> streamContainerLogs(String serverId, String containerId) {
    final key = '$serverId:$containerId';

    if (_logControllers.containsKey(key)) {
      return _logControllers[key]!.stream;
    }

    final controller = StreamController<String>.broadcast();
    _logControllers[key] = controller;

    _connectLogsWebSocket(serverId, containerId, controller);

    return controller.stream;
  }

  @override
  Stream<ContainerEvent> watchContainerEvents(String serverId) {
    if (_eventControllers.containsKey(serverId)) {
      return _eventControllers[serverId]!.stream;
    }

    final controller = StreamController<ContainerEvent>.broadcast();
    _eventControllers[serverId] = controller;

    _connectEventsWebSocket(serverId, controller);

    return controller.stream;
  }

  ApiClient _getClient(String serverId) {
    return serverRepository.getClient(serverId);
  }

  Future<void> _connectLogsWebSocket(
    String serverId,
    String containerId,
    StreamController<String> controller,
  ) async {
    // TODO: Implement WebSocket connection for logs
  }

  Future<void> _connectEventsWebSocket(
    String serverId,
    StreamController<ContainerEvent> controller,
  ) async {
    // TODO: Implement WebSocket connection for events
  }
}
