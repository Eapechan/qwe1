import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double gridOpacity;
  final double glowOpacity;
  final Color? ambientColor;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.gradient,
    this.gridOpacity = 0.03,
    this.glowOpacity = 0.04,
    this.ambientColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ambientColor ?? theme.colorScheme.primary;
    final defaultGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.colorScheme.background,
        theme.colorScheme.surface.withOpacity(0.5),
        theme.colorScheme.background,
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? defaultGradient,
      ),
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: _buildNoiseTexture(theme),
          ),
          Positioned.fill(
            child: _buildGrid(theme),
          ),
          Positioned.fill(
            child: _buildGlow(theme, primary),
          ),
          Positioned.fill(
            child: _buildSecondaryGlow(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildNoiseTexture(ThemeData theme) {
    return CustomPaint(
      painter: _NoisePainter(
        color: theme.colorScheme.onSurface.withOpacity(0.015),
      ),
    );
  }

  Widget _buildGrid(ThemeData theme) {
    return CustomPaint(
      painter: _GridPainter(
        color: theme.colorScheme.onSurface.withOpacity(gridOpacity),
        spacing: 32,
        lineWidth: 0.5,
      ),
    );
  }

  Widget _buildGlow(ThemeData theme, Color primary) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 500,
          height: 500,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primary.withOpacity(glowOpacity),
                primary.withOpacity(glowOpacity * 0.3),
                Colors.transparent,
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryGlow(ThemeData theme) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.secondary.withOpacity(0.02),
                Colors.transparent,
              ],
              stops: const [0, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final random = Random(42);

    for (double x = 0; x < size.width; x += 3) {
      for (double y = 0; y < size.height; y += 3) {
        if (random.nextDouble() > 0.5) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, 1.5, 1.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter old) => old.color != color;
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.color,
    required this.spacing,
    required this.lineWidth,
  });

  final Color color;
  final double spacing;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.color != color || old.spacing != spacing;
}
