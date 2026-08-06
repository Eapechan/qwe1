import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/widgets/progress_ring.dart';
import 'dart:math' as math;

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (progress != null)
              ProgressRing(
                progress: progress!,
                size: 40,
                strokeWidth: 4,
                color: color,
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.onSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      )
        .animate()
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms)
        .fadeIn(duration: 300.ms),
    );
  }
}