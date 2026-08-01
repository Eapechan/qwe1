// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerDto _$ContainerDtoFromJson(Map<String, dynamic> json) => ContainerDto(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      state: json['state'] as String,
      status: json['status'] as String? ?? '',
      health: json['health'] as String? ?? '',
      ports: (json['ports'] as List<dynamic>?)
              ?.map((e) => PortMappingDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cpuPercent: (json['cpuPercent'] as num?)?.toDouble() ?? 0.0,
      memoryBytes: (json['memoryBytes'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$ContainerDtoToJson(ContainerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'state': instance.state,
      'status': instance.status,
      'health': instance.health,
      'ports': instance.ports,
      'cpuPercent': instance.cpuPercent,
      'memoryBytes': instance.memoryBytes,
      'createdAt': instance.createdAt,
    };

PortMappingDto _$PortMappingDtoFromJson(Map<String, dynamic> json) =>
    PortMappingDto(
      host: json['host'] as String,
      container: json['container'] as String,
      protocol: json['protocol'] as String? ?? 'tcp',
    );

Map<String, dynamic> _$PortMappingDtoToJson(PortMappingDto instance) =>
    <String, dynamic>{
      'host': instance.host,
      'container': instance.container,
      'protocol': instance.protocol,
    };

ContainerInspectDto _$ContainerInspectDtoFromJson(Map<String, dynamic> json) =>
    ContainerInspectDto(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      state: json['state'] as String,
      config: json['config'] as Map<String, dynamic>? ?? const {},
      env: (json['env'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      mounts: (json['mounts'] as List<dynamic>?)
              ?.map((e) => MountPointDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      networkSettings:
          json['networkSettings'] as Map<String, dynamic>? ?? const {},
      labels: json['labels'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ContainerInspectDtoToJson(
        ContainerInspectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'state': instance.state,
      'config': instance.config,
      'env': instance.env,
      'mounts': instance.mounts,
      'networkSettings': instance.networkSettings,
      'labels': instance.labels,
    };

MountPointDto _$MountPointDtoFromJson(Map<String, dynamic> json) =>
    MountPointDto(
      type: json['type'] as String,
      source: json['source'] as String,
      destination: json['destination'] as String,
      rw: json['rw'] as bool? ?? false,
    );

Map<String, dynamic> _$MountPointDtoToJson(MountPointDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'source': instance.source,
      'destination': instance.destination,
      'rw': instance.rw,
    };
