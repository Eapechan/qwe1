import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HealthRing extends StatefulWidget {
  final double score;
  final double size;
  final double strokeWidth;

  const HealthRing({
    super.key,
    required this.score,
    this.size = 180,
    this.strokeWidth = 12,
  });

  @override
  State<HealthRing> createState() => _HealthRingState();
}

class _HealthRingState extends State<HealthRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sweepAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _sweepAnimation = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant HealthRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _controller.reset();
      _sweepAnimation = Tween<double>(begin: 0, end: widget.score / 100)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
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
    final color = _getHealthColor(widget.score);

    return AnimatedBuilder(
      animation: Listenable.merge([_sweepAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildTrack(color),
                _buildArc(color),
                Center(
                  child: Text(
                    '${(widget.score).round()}',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: -1,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrack(Color color) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.12),
          width: widget.strokeWidth,
        ),
      ),
    );
  }

  Widget _buildArc(Color color) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _HealthRingPainter(
        progress: _sweepAnimation.value,
        color: color,
        strokeWidth: widget.strokeWidth,
      ),
    );
  }

  Color _getHealthColor(double score) {
    if (score >= 75) return Theme.of(context).colorScheme.success;
    if (score >= 50) return Theme.of(context).colorScheme.warning;
    if (score > 0) return Theme.of(context).colorScheme.danger;
    return Theme.of(context).colorScheme.onSurfaceMuted;
  }
}

class _HealthRingPainter extends CustomPainter {
  _HealthRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * 3.1415926535 * progress.clamp(0.0, 1.0);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HealthRingPainter old) =>
      old.progress != progress || old.color != color;
}