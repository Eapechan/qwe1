// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerDto _$ServerDtoFromJson(Map<String, dynamic> json) => ServerDto(
      id: json['id'] as String,
      name: json['name'] as String,
      agentUrl: json['agentUrl'] as String,
      groupName: json['groupName'] as String? ?? '',
      readOnly: json['readOnly'] as bool? ?? false,
      fingerprintHash: json['fingerprintHash'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      deviceId: json['deviceId'] as String? ?? '',
      lastSeenAt: json['lastSeenAt'] as String?,
      createdAt: json['createdAt'] as String,
      agentVersion: json['agentVersion'] as String? ?? '',
      capabilities: json['capabilities'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ServerDtoToJson(ServerDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'agentUrl': instance.agentUrl,
      'groupName': instance.groupName,
      'readOnly': instance.readOnly,
      'fingerprintHash': instance.fingerprintHash,
      'status': instance.status,
      'deviceId': instance.deviceId,
      'lastSeenAt': instance.lastSeenAt,
      'createdAt': instance.createdAt,
      'agentVersion': instance.agentVersion,
      'capabilities': instance.capabilities,
    };
