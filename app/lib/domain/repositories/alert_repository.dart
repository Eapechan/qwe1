import 'package:qwe1/domain/entities/alert.dart';

abstract class AlertRepository {
  Future<List<Alert>> getAlerts(String serverId, {AlertSeverity? severity, DateTime? since});
  Future<void> acknowledgeAlert(String serverId, String alertId);
  Future<AlertThreshold> getThresholds(String serverId);
  Future<void> updateThresholds(String serverId, AlertThreshold thresholds);
  Stream<Alert> watchAlerts(String serverId);
}
