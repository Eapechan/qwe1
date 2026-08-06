import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final List<double> data;
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;

  const Sparkline({
    super.key,
    required this.data,
    this.width = 80,
    this.height = 32,
    this.color = const Color(0xFF06B6D4),
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Icon(
            Icons.show_chart_rounded,
            size: 16,
            color: color.withOpacity(0.3),
          ),
        ),
      );
    }

    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    final safeRange = range == 0 ? 1 : range;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          min: min,
          range: safeRange,
          color: color,
          strokeWidth: strokeWidth,
          width: width,
          height: height,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.min,
    required this.range,
    required this.color,
    required this.strokeWidth,
    required this.width,
    required this.height,
  });

  final List<double> data;
  final double min;
  final double range;
  final Color color;
  final double strokeWidth;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final stepX = width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = height - ((data[i] - min) / range * height * 0.8 + height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = height - ((data[i - 1] - min) / range * height * 0.8 + height * 0.1);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);

    if (data.isNotEmpty) {
      final lastX = (data.length - 1) * stepX;
      final lastY = height - ((data.last - min) / range * height * 0.8 + height * 0.1);

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastX, lastY), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.data != data || old.color != color;
}