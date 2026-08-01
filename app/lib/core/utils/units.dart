import 'package:qwe1/core/utils/formatters.dart';

class Units {
  Units._();

  static String cpu(double percent) => Formatters.formatPercent(percent);

  static String memory(int bytes) => Formatters.formatBytes(bytes);

  static String memoryPercent(double percent) => Formatters.formatPercent(percent);

  static String disk(int bytes) => Formatters.formatBytes(bytes);

  static String diskPercent(double percent) => Formatters.formatPercent(percent);

  static String network(double bytesPerSec) => Formatters.formatBytesPerSec(bytesPerSec);

  static String temperature(double celsius) => Formatters.formatCelsius(celsius);

  static String uptime(int seconds) => Formatters.formatDuration(seconds);

  static String load(List<double> load) {
    if (load.isEmpty) return '-';
    return load.map((e) => e.toStringAsFixed(2)).join(' / ');
  }
}
