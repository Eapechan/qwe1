import 'package:qwe1/domain/entities/metrics.dart';

class HealthScore {
  HealthScore._();

  static double calculate(HostMetrics metrics) {
    final host = metrics.host;
    double score = 100;

    score -= _cpuPenalty(host.cpu.percent);
    score -= _ramPenalty(host.memory.percent);
    score -= _diskPenalty(host.disk);
    score -= _tempPenalty(host.sensors);
    score -= _uptimePenalty(host.uptimeSeconds);

    return score.clamp(0, 100);
  }

  static double _cpuPenalty(double percent) {
    if (percent >= 90) return 25;
    if (percent >= 75) return 15;
    if (percent >= 50) return 5;
    return 0;
  }

  static double _ramPenalty(double percent) {
    if (percent >= 90) return 20;
    if (percent >= 75) return 12;
    if (percent >= 50) return 4;
    return 0;
  }

  static double _diskPenalty(List<DiskMetrics> disks) {
    if (disks.isEmpty) return 0;
    final maxDisk = disks.reduce((a, b) => a.percent > b.percent ? a : b);
    if (maxDisk.percent >= 90) return 20;
    if (maxDisk.percent >= 75) return 10;
    if (maxDisk.percent >= 50) return 3;
    return 0;
  }

  static double _tempPenalty(List<TempSensor> sensors) {
    if (sensors.isEmpty) return 0;
    final maxTemp = sensors.reduce((a, b) => a.celsius > b.celsius ? a : b);
    if (maxTemp.celsius >= 85) return 20;
    if (maxTemp.celsius >= 75) return 10;
    if (maxTemp.celsius >= 65) return 4;
    return 0;
  }

  static double _uptimePenalty(int uptimeSeconds) {
    final days = uptimeSeconds / 86400;
    if (days < 1) return 5;
    if (days < 7) return 2;
    return 0;
  }

  static String label(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }
}