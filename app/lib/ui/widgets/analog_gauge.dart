import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qwe1/ui/theme/app_theme.dart';

class AnalogGauge extends StatefulWidget {
  final double value;
  final double size;
  final String? label;
  final String? unit;

  const AnalogGauge({
    super.key,
    required this.value,
    this.size = 200,
    this.label,
    this.unit,
  });

  @override
  State<AnalogGauge> createState() => _AnalogGaugeState();
}

class _AnalogGaugeState extends State<AnalogGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _needleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _needleAnimation = Tween<double>(begin: 0, end: widget.value / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnalogGauge old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _controller.reset();
      _needleAnimation = Tween<double>(
        begin: _needleAnimation.value,
        end: widget.value / 100,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(widget.value, theme);

    return AnimatedBuilder(
      animation: _needleAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugePainter(
                  progress: _needleAnimation.value,
                  color: color,
                  trackColor: theme.colorScheme.surfaceVariant,
                  tickColor: context.onSurfaceMuted,
                ),
              ),
              // Center cap
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Value text
              Positioned(
                bottom: widget.size * 0.22,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.value.round()}',
                      style: TextStyle(
                        fontSize: widget.size * 0.2,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -1,
                      ),
                    ),
                    if (widget.unit != null)
                      Text(
                        widget.unit!,
                        style: TextStyle(
                          fontSize: widget.size * 0.065,
                          fontWeight: FontWeight.w600,
                          color: context.onSurfaceMuted,
                          letterSpacing: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColor(double value, ThemeData theme) {
    if (value >= 75) return context.danger;
    if (value >= 50) return context.warning;
    if (value >= 25) return context.primary;
    return context.success;
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.tickColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final Color tickColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    const startAngle = 0.75 * pi;
    const sweepAngle = 1.5 * pi;
    const totalAngle = 1.5 * pi;

    // Track arc
    final trackPaint = Paint()
      ..color = trackColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + totalAngle,
        colors: [color.withOpacity(0.4), color],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final currentSweep = totalAngle * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      progressPaint,
    );

    // Tick marks
    final tickPaint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 10; i++) {
      final angle = startAngle + (totalAngle * i / 10);
      final isMajor = i % 5 == 0;
      final innerRadius = radius - (isMajor ? 14 : 10);
      final outerRadius = radius - 4;

      tickPaint.color = (i / 10) >= progress
          ? tickColor.withOpacity(0.25)
          : color.withOpacity(0.6);

      tickPaint.strokeWidth = isMajor ? 2 : 1;

      canvas.drawLine(
        Offset(center.dx + innerRadius * cos(angle),
            center.dy + innerRadius * sin(angle)),
        Offset(center.dx + outerRadius * cos(angle),
            center.dy + outerRadius * sin(angle)),
        tickPaint,
      );
    }

    // Minor tick marks (between major ticks)
    final minorTickPaint = Paint()
      ..strokeWidth = 0.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 50; i++) {
      final angle = startAngle + (totalAngle * i / 50);
      final innerRadius = radius - 7;
      final outerRadius = radius - 4;

      minorTickPaint.color = tickColor.withOpacity(0.1);

      canvas.drawLine(
        Offset(center.dx + innerRadius * cos(angle),
            center.dy + innerRadius * sin(angle)),
        Offset(center.dx + outerRadius * cos(angle),
            center.dy + outerRadius * sin(angle)),
        minorTickPaint,
      );
    }

    // Needle
    final needleAngle = startAngle + totalAngle * progress.clamp(0.0, 1.0);
    final needleLength = radius - 20;

    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx + needleLength * cos(needleAngle),
        center.dy + needleLength * sin(needleAngle),
      ),
      needlePaint,
    );

    // Glow at needle tip
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(
      Offset(
        center.dx + needleLength * cos(needleAngle),
        center.dy + needleLength * sin(needleAngle),
      ),
      4,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}
