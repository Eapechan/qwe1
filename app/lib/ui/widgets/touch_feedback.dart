import 'package:flutter/material.dart';

class TouchFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final Duration duration;

  const TouchFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 180),
  });

  @override
  State<TouchFeedback> createState() => _TouchFeedbackState();
}

class _TouchFeedbackState extends State<TouchFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
    _controller.forward(from: 0);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (1.0 - widget.scale) * _controller.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}