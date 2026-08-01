import 'package:flutter/material.dart';
import 'package:qwe1/domain/entities/alert.dart';
import 'package:qwe1/core/utils/formatters.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSeverityIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeLabel(alert.type),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        Formatters.formatRelative(alert.at),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (!alert.acked)
                  TextButton(
                    onPressed: onAcknowledge,
                    child: const Text('Ack'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityIcon() {
    IconData icon;
    Color color;

    switch (alert.severity) {
      case AlertSeverity.critical:
        icon = Icons.error;
        color = Colors.red;
        break;
      case AlertSeverity.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case AlertSeverity.info:
        icon = Icons.info;
        color = Colors.blue;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
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
