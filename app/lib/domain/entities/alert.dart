import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';

@freezed
class Alert with _$Alert {
  const factory Alert({
    required String id,
    required String serverId,
    required String type,
    required AlertSeverity severity,
    required String message,
    required DateTime at,
    @Default(false) bool acked,
    @Default({}) Map<String, dynamic> context,
  }) = _Alert;
}

enum AlertSeverity {
  info,
  warning,
  critical,
}

@freezed
class AlertThreshold with _$AlertThreshold {
  const factory AlertThreshold({
    @Default(90.0) double cpuPercent,
    @Default(60) int cpuForSeconds,
    @Default(90.0) double memPercent,
    @Default(60) int memForSeconds,
    @Default(85.0) double diskPercent,
    @Default(300) int diskForSeconds,
    @Default(75.0) double tempCelsius,
    @Default(300) int tempForSeconds,
    @Default(true) bool containerDown,
  }) = _AlertThreshold;
}
