import 'package:flutter/material.dart';

class PulseIndicator extends StatefulWidget {
  final String status;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const PulseIndicator({
    super.key,
    required this.status,
    this.size = 12,
    this.activeColor = const Color(0xFF22C55E),
    this.inactiveColor = const Color(0xFFEF4444),
  });

  @override
  State<PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _ringAnimation;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _ringAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _updateStatus();
  }

  @override
  void didUpdateWidget(covariant PulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _updateStatus();
    }
  }

  void _updateStatus() {
    final isActive = widget.status.toLowerCase() == 'online' ||
        widget.status.toLowerCase() == 'connected' ||
        widget.status.toLowerCase() == 'running' ||
        widget.status.toLowerCase() == 'healthy';

    if (isActive != _isActive) {
      setState(() => _isActive = isActive);
      if (_isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _isActive ? widget.activeColor : widget.inactiveColor;

    return SizedBox(
      width: widget.size * 3,
      height: widget.size * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isActive) ...[
            AnimatedBuilder(
              animation: _ringAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.size * _ringAnimation.value * 3,
                  height: widget.size * _ringAnimation.value * 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.size * _pulseAnimation.value,
                  height: widget.size * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                  ),
                );
              },
            ),
          ],
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}