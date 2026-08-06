import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qwe1/domain/entities/container.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/theme/app_typography.dart';
import 'package:qwe1/ui/widgets/pulse_indicator.dart';
import 'package:qwe1/ui/widgets/sparkline.dart';
import 'package:qwe1/core/utils/units.dart';

class ContainerCard extends StatelessWidget {
  const ContainerCard({
    super.key,
    required this.container,
    required this.onTap,
    this.onStart,
    this.onStop,
    this.onRestart,
  });

  final Container container;
  final VoidCallback onTap;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    final isRunning = container.state.toLowerCase() == 'running';
    final color = isRunning
        ? context.statusColor('healthy')
        : context.statusColor('offline');

    return AnimatedCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              context.surface,
              context.surfaceVariant.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isRunning ? Icons.circle_rounded : Icons.pause_circle_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        container.name.isNotEmpty
                            ? container.name
                            : container.id.substring(0, 12),
                        style: AppTypography.headingSmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        container.image,
                        style: AppTypography.bodySmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    if (!isRunning && onStart != null)
                      const PopupMenuItem(
                        value: 'start',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Start'),
                          ],
                        ),
                      ),
                    if (isRunning && onStop != null)
                      const PopupMenuItem(
                        value: 'stop',
                        child: Row(
                          children: [
                            Icon(Icons.stop_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Stop'),
                          ],
                        ),
                      ),
                    if (isRunning && onRestart != null)
                      const PopupMenuItem(
                        value: 'restart',
                        child: Row(
                          children: [
                            Icon(Icons.restart_alt_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Restart'),
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
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: context.onSurfaceMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isRunning) ...[
              Row(
                children: [
                  _buildMetricChip(
                    context,
                    Icons.speed_rounded,
                    Units.cpu(container.cpuPercent),
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  _buildMetricChip(
                    context,
                    Icons.memory_rounded,
                    Units.memory(container.memoryBytes),
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  if (container.health.isNotEmpty)
                    _buildHealthBadge(context, container.health),
                  const Spacer(),
                  Sparkline(
                    data: _generateDummyData(),
                    width: 48,
                    height: 24,
                    color: color,
                    strokeWidth: 1.5,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(
    BuildContext context,
    IconData icon,
    String value, {
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: context.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            value,
            style: AppTypography.labelSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(BuildContext context, String health) {
    final healthColor = health.toLowerCase() == 'healthy'
        ? context.success
        : health.toLowerCase() == 'unhealthy'
            ? context.danger
            : context.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: healthColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        health.toUpperCase(),
        style: AppTypography.labelSmall(context).copyWith(
          color: healthColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<double> _generateDummyData() {
    return List.generate(12, (i) => 30 + (i * 5).toDouble() + (i % 3 * 10));
  }
}