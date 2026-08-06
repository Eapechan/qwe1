import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double gridOpacity;
  final double glowOpacity;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.gradient,
    this.gridOpacity = 0.03,
    this.glowOpacity = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            child: _buildGrid(theme),
          ),
          Positioned.fill(
            child: _buildGlow(theme),
          ),
        ],
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

  Widget _buildGlow(ThemeData theme) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(glowOpacity),
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