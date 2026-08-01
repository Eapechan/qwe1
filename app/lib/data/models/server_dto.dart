import 'package:json_annotation/json_annotation.dart';
import 'package:qwe1/domain/entities/server.dart';

part 'server_dto.g.dart';

@JsonSerializable()
class ServerDto {
  final String id;
  final String name;
  final String agentUrl;
  final String groupName;
  final bool readOnly;
  final String fingerprintHash;
  final String status;
  final String deviceId;
  final String? lastSeenAt;
  final String createdAt;
  final String agentVersion;
  final Map<String, dynamic> capabilities;

  ServerDto({
    required this.id,
    required this.name,
    required this.agentUrl,
    this.groupName = '',
    this.readOnly = false,
    this.fingerprintHash = '',
    this.status = 'unknown',
    this.deviceId = '',
    this.lastSeenAt,
    required this.createdAt,
    this.agentVersion = '',
    this.capabilities = const {},
  });

  factory ServerDto.fromJson(Map<String, dynamic> json) => _$ServerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerDtoToJson(this);

  Server toEntity() => Server(
        id: id,
        name: name,
        agentUrl: agentUrl,
        groupName: groupName,
        readOnly: readOnly,
        fingerprintHash: fingerprintHash,
        status: status,
        deviceId: deviceId,
        lastSeenAt: lastSeenAt != null ? DateTime.parse(lastSeenAt!) : null,
        createdAt: DateTime.parse(createdAt),
        agentVersion: agentVersion,
        capabilities: capabilities,
      );

  factory ServerDto.fromEntity(Server server) => ServerDto(
        id: server.id,
        name: server.name,
        agentUrl: server.agentUrl,
        groupName: server.groupName,
        readOnly: server.readOnly,
        fingerprintHash: server.fingerprintHash,
        status: server.status,
        deviceId: server.deviceId,
        lastSeenAt: server.lastSeenAt?.toIso8601String(),
        createdAt: server.createdAt.toIso8601String(),
        agentVersion: server.agentVersion,
        capabilities: server.capabilities,
      );
}
