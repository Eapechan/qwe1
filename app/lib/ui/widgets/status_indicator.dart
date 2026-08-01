import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
  });

  final String status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'connected':
        return Colors.green;
      case 'offline':
      case 'disconnected':
        return Colors.red;
      case 'degraded':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
