import 'package:flutter/material.dart';
import 'package:qwe1/core/utils/formatters.dart';
import 'package:qwe1/domain/entities/alert.dart';
import 'package:qwe1/ui/theme/app_theme.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    this.onAcknowledge,
  });

  final Alert alert;
  final VoidCallback? onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final severity = _getSeverityConfig(context, alert.severity);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: severity.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                severity.icon,
                color: severity.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getTypeLabel(alert.type),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(
                        Formatters.formatRelative(alert.at),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.onSurfaceMuted,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.onSurfaceMuted,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!alert.acked && onAcknowledge != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAcknowledge,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                tooltip: 'Acknowledge',
                color: context.onSurfaceMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _SeverityConfig _getSeverityConfig(BuildContext context, AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return _SeverityConfig(
          color: context.danger,
          icon: Icons.error_rounded,
        );
      case AlertSeverity.warning:
        return _SeverityConfig(
          color: context.warning,
          icon: Icons.warning_rounded,
        );
      case AlertSeverity.info:
        return _SeverityConfig(
          color: context.info,
          icon: Icons.info_rounded,
        );
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'host.cpu':
        return 'CPU Alert';
      case 'host.memory':
        return 'Memory Alert';
      case 'host.disk':
        return 'Disk Alert';
      case 'host.temp':
        return 'Temperature Alert';
      case 'docker.container_down':
        return 'Container Down';
      default:
        return type;
    }
  }
}

class _SeverityConfig {
  const _SeverityConfig({required this.color, required this.icon});
  final Color color;
  final IconData icon;
}
