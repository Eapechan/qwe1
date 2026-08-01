import 'package:flutter/material.dart' as material;
import 'package:qwe1/domain/entities/container.dart' as domain;
import 'package:qwe1/ui/widgets/status_indicator.dart';

class ContainerCard extends material.StatelessWidget {
  const ContainerCard({
    super.key,
    required this.container,
    required this.onTap,
    this.onStart,
    this.onStop,
    this.onRestart,
  });

  final domain.Container container;
  final material.VoidCallback onTap;
  final material.VoidCallback? onStart;
  final material.VoidCallback? onStop;
  final material.VoidCallback? onRestart;

  @override
  material.Widget build(material.BuildContext context) {
    final isRunning = container.state.toLowerCase() == 'running';

    return material.Card(
      child: material.InkWell(
        onTap: onTap,
        borderRadius: material.BorderRadius.circular(20),
        child: material.Padding(
          padding: const material.EdgeInsets.all(14),
          child: material.Column(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Row(
                children: [
                  StatusIndicator(
                    status: isRunning ? 'online' : 'offline',
                    size: 10,
                  ),
                  const material.SizedBox(width: 12),
                  material.Expanded(
                    child: material.Column(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        material.Text(
                          container.name.isNotEmpty ? container.name : container.id.substring(0, 12),
                          style: material.Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: material.FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: material.TextOverflow.ellipsis,
                        ),
                        const material.SizedBox(height: 2),
                        material.Text(
                          container.image,
                          style: material.Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: material.Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: material.TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  material.PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      if (!isRunning && onStart != null)
                        const material.PopupMenuItem(
                          value: 'start',
                          child: material.Row(
                            children: [
                              material.Icon(material.Icons.play_arrow_rounded, size: 20),
                              material.SizedBox(width: 8),
                              material.Text('Start'),
                            ],
                          ),
                        ),
                      if (isRunning && onStop != null)
                        const material.PopupMenuItem(
                          value: 'stop',
                          child: material.Row(
                            children: [
                              material.Icon(material.Icons.stop_rounded, size: 20),
                              material.SizedBox(width: 8),
                              material.Text('Stop'),
                            ],
                          ),
                        ),
                      if (isRunning && onRestart != null)
                        const material.PopupMenuItem(
                          value: 'restart',
                          child: material.Row(
                            children: [
                              material.Icon(material.Icons.restart_alt_rounded, size: 20),
                              material.SizedBox(width: 8),
                              material.Text('Restart'),
                            ],
                          ),
                        ),
                    ],
                    onSelected: (value) {
                      switch (value) {
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
                    },
                    icon: material.Icon(
                      material.Icons.more_vert_rounded,
                      color: material.Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
              if (isRunning) ...[
                const material.SizedBox(height: 12),
                material.Row(
                  children: [
                    _buildMetricBadge(
                      context,
                      material.Icons.speed_rounded,
                      '${container.cpuPercent.toStringAsFixed(1)}%',
                    ),
                    const material.SizedBox(width: 8),
                    _buildMetricBadge(
                      context,
                      material.Icons.memory_rounded,
                      _formatBytes(container.memoryBytes),
                    ),
                    if (container.health.isNotEmpty) ...[
                      const material.SizedBox(width: 8),
                      _buildHealthBadge(context, container.health),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  material.Widget _buildMetricBadge(material.BuildContext context, material.IconData icon, String value) {
    return material.Container(
      padding: const material.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: material.BoxDecoration(
        color: material.Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: material.BorderRadius.circular(8),
      ),
      child: material.Row(
        mainAxisSize: material.MainAxisSize.min,
        children: [
          material.Icon(icon, size: 12, color: material.Theme.of(context).colorScheme.onSurfaceVariant),
          const material.SizedBox(width: 4),
          material.Text(
            value,
            style: material.Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: material.FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  material.Widget _buildHealthBadge(material.BuildContext context, String health) {
    final color = health.toLowerCase() == 'healthy'
        ? material.Colors.green
        : health.toLowerCase() == 'unhealthy'
            ? material.Colors.red
            : material.Colors.orange;

    return material.Container(
      padding: const material.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: material.BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: material.BorderRadius.circular(8),
      ),
      child: material.Text(
        health.toUpperCase(),
        style: material.Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: material.FontWeight.w700,
              letterSpacing: 0.5,
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
}
