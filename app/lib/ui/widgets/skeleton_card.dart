import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:qwe1/ui/theme/app_theme.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme._lightColors;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: colors.border,
                  highlightColor: colors.shimmer,
                  child: const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressionIndicator(),
                  ),
                ),
                const SizedBox(width: 12),
                Shimmer.fromColors(
                  baseColor: colors.border,
                  highlightColor: colors.shimmer,
                  child: Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: colors.border,
              highlightColor: colors.shimmer,
              child: Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressionIndicator extends StatelessWidget {
  const CircularProgressionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 12,
      height: 12,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
      ),
    );
  }
}