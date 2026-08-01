import 'dart:async';

import 'package:qwe1/domain/entities/alert.dart';
import 'package:qwe1/domain/repositories/alert_repository.dart';
import 'package:qwe1/domain/repositories/server_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl({required this.serverRepository});

  final ServerRepository serverRepository;

  @override
  Future<List<Alert>> getAlerts(String serverId, {AlertSeverity? severity, DateTime? since}) async {
    final client = serverRepository.getClient(serverId);
    final response = await client.get('/alerts', queryParameters: {
      if (severity != null) 'severity': severity.name,
    });

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List;

    return items.map((e) {
      final item = e as Map<String, dynamic>;
      return Alert(
        id: item['id'] as String,
        serverId: serverId,
        type: item['type'] as String? ?? '',
        severity: _severityFromString(item['severity'] as String? ?? 'info'),
        message: item['message'] as String? ?? '',
        at: DateTime.parse(item['at'] as String? ?? DateTime.now().toIso8601String()),
        acked: item['acked'] as bool? ?? false,
        context: Map<String, dynamic>.from(item['context'] as Map? ?? {}),
      );
    }).toList();
  }

  @override
  Future<void> acknowledgeAlert(String serverId, String alertId) async {
    final client = serverRepository.getClient(serverId);
    await client.put('/alerts/$alertId/ack');
  }

  @override
  Future<AlertThreshold> getThresholds(String serverId) async {
    final client = serverRepository.getClient(serverId);
    final response = await client.get('/alerts/thresholds');
    final data = response.data as Map<String, dynamic>;

    return AlertThreshold(
      cpuPercent: (data['cpuPercent'] as num?)?.toDouble() ?? 90.0,
      cpuForSeconds: data['cpuForSeconds'] as int? ?? 60,
      memPercent: (data['memPercent'] as num?)?.toDouble() ?? 90.0,
      memForSeconds: data['memForSeconds'] as int? ?? 60,
      diskPercent: (data['diskPercent'] as num?)?.toDouble() ?? 85.0,
      diskForSeconds: data['diskForSeconds'] as int? ?? 300,
      tempCelsius: (data['tempCelsius'] as num?)?.toDouble() ?? 75.0,
      tempForSeconds: data['tempForSeconds'] as int? ?? 300,
      containerDown: data['containerDown'] as bool? ?? true,
    );
  }

  @override
  Future<void> updateThresholds(String serverId, AlertThreshold thresholds) async {
    final client = serverRepository.getClient(serverId);
    await client.put('/alerts/thresholds', data: {
      'cpuPercent': thresholds.cpuPercent,
      'cpuForSeconds': thresholds.cpuForSeconds,
      'memPercent': thresholds.memPercent,
      'memForSeconds': thresholds.memForSeconds,
      'diskPercent': thresholds.diskPercent,
      'diskForSeconds': thresholds.diskForSeconds,
      'tempCelsius': thresholds.tempCelsius,
      'tempForSeconds': thresholds.tempForSeconds,
      'containerDown': thresholds.containerDown,
    });
  }

  @override
  Stream<Alert> watchAlerts(String serverId) {
    return const Stream.empty();
  }

  AlertSeverity _severityFromString(String value) {
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
}
