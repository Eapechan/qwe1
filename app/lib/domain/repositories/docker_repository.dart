import 'package:qwe1/domain/entities/container.dart';

abstract class DockerRepository {
  Future<List<Container>> getContainers(String serverId, {String? filter});
  Future<Container> getContainer(String serverId, String containerId);
  Future<ContainerInspect> inspectContainer(String serverId, String containerId);
  Future<void> startContainer(String serverId, String containerId);
  Future<void> stopContainer(String serverId, String containerId);
  Future<void> restartContainer(String serverId, String containerId);
  Future<void> pauseContainer(String serverId, String containerId);
  Future<void> unpauseContainer(String serverId, String containerId);
  Future<void> killContainer(String serverId, String containerId, {String? signal});
  Future<void> removeContainer(String serverId, String containerId, {bool force = false});
  Future<List<String>> getContainerLogs(String serverId, String containerId, {int tail = 200});
  Stream<String> streamContainerLogs(String serverId, String containerId);
  Stream<ContainerEvent> watchContainerEvents(String serverId);
}

class ContainerEvent {
  final String type;
  final String action;
  final String name;
  final DateTime timestamp;

  ContainerEvent({
    required this.type,
    required this.action,
    required this.name,
    required this.timestamp,
  });
}
