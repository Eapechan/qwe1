// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertDto _$AlertDtoFromJson(Map<String, dynamic> json) => AlertDto(
      id: json['id'] as String,
      serverId: json['serverId'] as String,
      type: json['type'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      at: json['at'] as String,
      acked: json['acked'] as bool? ?? false,
      context: json['context'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AlertDtoToJson(AlertDto instance) => <String, dynamic>{
      'id': instance.id,
      'serverId': instance.serverId,
      'type': instance.type,
      'severity': instance.severity,
      'message': instance.message,
      'at': instance.at,
      'acked': instance.acked,
      'context': instance.context,
    };
