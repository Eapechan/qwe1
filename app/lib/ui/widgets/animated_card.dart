import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double elevation;
  final Duration animationDuration;
  final Curve animationCurve;
  final double delay;
  final bool animateEntry;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.elevation = 0,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.delay = 0,
    this.animateEntry = true,
  });

  @override
  Widget build(BuildContext context) {
    final result = Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.04),
        child: child,
      ),
    );

    if (!animateEntry) return result;

    return result.animate(delay: Duration(milliseconds: delay.toInt()))
        .fadeIn(duration: animationDuration, curve: animationCurve)
        .slide(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
          curve: animationCurve,
          duration: animationDuration,
        );
  }
}