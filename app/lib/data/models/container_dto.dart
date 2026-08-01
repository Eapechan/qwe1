import 'package:json_annotation/json_annotation.dart';
import 'package:qwe1/domain/entities/container.dart';

part 'container_dto.g.dart';

@JsonSerializable()
class ContainerDto {
  final String id;
  final String name;
  final String image;
  final String state;
  final String status;
  final String health;
  final List<PortMappingDto> ports;
  final double cpuPercent;
  final int memoryBytes;
  final String? createdAt;

  ContainerDto({
    required this.id,
    required this.name,
    required this.image,
    required this.state,
    this.status = '',
    this.health = '',
    this.ports = const [],
    this.cpuPercent = 0.0,
    this.memoryBytes = 0,
    this.createdAt,
  });

  factory ContainerDto.fromJson(Map<String, dynamic> json) => _$ContainerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerDtoToJson(this);

  Container toEntity() => Container(
        id: id,
        name: name,
        image: image,
        state: state,
        status: status,
        health: health,
        ports: ports.map((e) => e.toEntity()).toList(),
        cpuPercent: cpuPercent,
        memoryBytes: memoryBytes,
        createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      );
}

@JsonSerializable()
class PortMappingDto {
  final String host;
  final String container;
  final String protocol;

  PortMappingDto({required this.host, required this.container, this.protocol = 'tcp'});

  factory PortMappingDto.fromJson(Map<String, dynamic> json) => _$PortMappingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PortMappingDtoToJson(this);

  PortMapping toEntity() => PortMapping(host: host, container: container, protocol: protocol);
}

@JsonSerializable()
class ContainerInspectDto {
  final String id;
  final String name;
  final String image;
  final String state;
  final Map<String, dynamic> config;
  final List<String> env;
  final List<MountPointDto> mounts;
  final Map<String, dynamic> networkSettings;
  final Map<String, dynamic> labels;

  ContainerInspectDto({
    required this.id,
    required this.name,
    required this.image,
    required this.state,
    this.config = const {},
    this.env = const [],
    this.mounts = const [],
    this.networkSettings = const {},
    this.labels = const {},
  });

  factory ContainerInspectDto.fromJson(Map<String, dynamic> json) => _$ContainerInspectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerInspectDtoToJson(this);

  ContainerInspect toEntity() => ContainerInspect(
        id: id,
        name: name,
        image: image,
        state: state,
        config: config,
        env: env,
        mounts: mounts.map((e) => e.toEntity()).toList(),
        networkSettings: networkSettings,
        labels: labels,
      );
}

@JsonSerializable()
class MountPointDto {
  final String type;
  final String source;
  final String destination;
  final bool rw;

  MountPointDto({required this.type, required this.source, required this.destination, this.rw = false});

  factory MountPointDto.fromJson(Map<String, dynamic> json) => _$MountPointDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MountPointDtoToJson(this);

  MountPoint toEntity() => MountPoint(type: type, source: source, destination: destination, rw: rw);
}
