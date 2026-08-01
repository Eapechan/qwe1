import 'package:flutter/material.dart';
import 'package:qwe1/domain/entities/container.dart' as domain;

class ContainerCard extends StatelessWidget {
  const ContainerCard({
    super.key,
    required this.container,
    required this.onTap,
    this.onStart,
    this.onStop,
    this.onRestart,
  });

  final domain.Container container;
  final VoidCallback onTap;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIndicator(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          container.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          container.image,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: _handleAction,
                    itemBuilder: (context) => [
                      if (container.state != 'running')
                        const PopupMenuItem(value: 'start', child: Text('Start')),
                      if (container.state == 'running') ...[
                        const PopupMenuItem(value: 'stop', child: Text('Stop')),
                        const PopupMenuItem(value: 'restart', child: Text('Restart')),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricBadge(
                    context,
                    'CPU',
                    '${container.cpuPercent.toStringAsFixed(1)}%',
                  ),
                  const SizedBox(width: 8),
                  _buildMetricBadge(
                    context,
                    'MEM',
                    _formatBytes(container.memoryBytes),
                  ),
                  const Spacer(),
                  if (container.health.isNotEmpty)
                    _buildHealthBadge(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color color;
    switch (container.state) {
      case 'running':
        color = Colors.green;
        break;
      case 'exited':
        color = Colors.red;
        break;
      case 'paused':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildMetricBadge(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(BuildContext context) {
    Color color;
    switch (container.health) {
      case 'healthy':
        color = Colors.green;
        break;
      case 'unhealthy':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        container.health.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _handleAction(String action) {
    switch (action) {
      case 'start':
        onStart?.call();
        break;
      case 'stop':
        onStop?.call();
        break;
      case 'restart':
        onRestart?.call();
        break;
    }
  }
}
