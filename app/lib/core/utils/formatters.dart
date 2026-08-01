import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatBytesPerSec(double bytesPerSec) {
    if (bytesPerSec < 1024) return '${bytesPerSec.toStringAsFixed(0)} B/s';
    if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) return '$days d $hours h';
    if (hours > 0) return '$hours h $minutes m';
    return '$minutes m';
  }

  static String formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatCelsius(double value) {
    return '${value.toStringAsFixed(1)}°C';
  }

  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat.jm().format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return formatDate(date);
  }

  static String truncateFingerprint(String fingerprint, {int segmentCount = 4}) {
    final segments = fingerprint.split(':');
    if (segments.length <= segmentCount) return fingerprint;
    return '${segments.take(segmentCount).join(':')}:...';
  }
}
