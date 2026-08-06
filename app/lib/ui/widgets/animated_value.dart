import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedValue extends StatefulWidget {
  final double targetValue;
  final String Function(double value) formatter;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AnimatedValue({
    super.key,
    required this.targetValue,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedValue> createState() => _AnimatedValueState();
}

class _AnimatedValueState extends State<AnimatedValue>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.targetValue)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _animation.addListener(() {
      setState(() => _currentValue = _animation.value);
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _controller.reset();
      _animation = Tween<double>(begin: _currentValue, end: widget.targetValue)
          .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _animation.addListener(() {
        setState(() => _currentValue = _animation.value);
      });
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
    return AnimatedSwitcher(
      duration: widget.duration,
      child: Text(
        widget.formatter(_currentValue),
        key: ValueKey(_currentValue),
        style: widget.style,
      ),
    );
  }
}