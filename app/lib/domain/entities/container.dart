import 'package:freezed_annotation/freezed_annotation.dart';

part 'container.freezed.dart';

@freezed
class Container with _$Container {
  const factory Container({
    required String id,
    required String name,
    required String image,
    required String state,
    @Default('') String status,
    @Default('') String health,
    @Default([]) List<PortMapping> ports,
    @Default(0.0) double cpuPercent,
    @Default(0) int memoryBytes,
    DateTime? createdAt,
  }) = _Container;
}

@freezed
class PortMapping with _$PortMapping {
  const factory PortMapping({
    required String host,
    required String container,
    @Default('tcp') String protocol,
  }) = _PortMapping;
}

@freezed
class ContainerInspect with _$ContainerInspect {
  const factory ContainerInspect({
    required String id,
    required String name,
    required String image,
    required String state,
    @Default({}) Map<String, dynamic> config,
    @Default([]) List<String> env,
    @Default([]) List<MountPoint> mounts,
    @Default({}) Map<String, dynamic> networkSettings,
    @Default({}) Map<String, dynamic> labels,
  }) = _ContainerInspect;
}

@freezed
class MountPoint with _$MountPoint {
  const factory MountPoint({
    required String type,
    required String source,
    required String destination,
    @Default(false) bool rw,
  }) = _MountPoint;
}
