import 'package:json_annotation/json_annotation.dart';
import 'package:qwe1/domain/entities/alert.dart';

part 'alert_dto.g.dart';

@JsonSerializable()
class AlertDto {
  final String id;
  final String serverId;
  final String type;
  final String severity;
  final String message;
  final String at;
  final bool acked;
  final Map<String, dynamic> context;

  AlertDto({
    required this.id,
    required this.serverId,
    required this.type,
    required this.severity,
    required this.message,
    required this.at,
    this.acked = false,
    this.context = const {},
  });

  factory AlertDto.fromJson(Map<String, dynamic> json) => _$AlertDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AlertDtoToJson(this);

  Alert toEntity() => Alert(
        id: id,
        serverId: serverId,
        type: type,
        severity: _severityFromString(severity),
        message: message,
        at: DateTime.parse(at),
        acked: acked,
        context: context,
      );

  static AlertSeverity _severityFromString(String value) {
    switch (value.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'warning':
        return AlertSeverity.warning;
      case 'info':
      default:
        return AlertSeverity.info;
    }
  }

  static String _severityToString(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 'critical';
      case AlertSeverity.warning:
        return 'warning';
      case AlertSeverity.info:
        return 'info';
    }
  }
}
