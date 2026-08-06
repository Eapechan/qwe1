import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qwe1/domain/entities/metrics.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/widgets/animated_background.dart';
import 'package:qwe1/ui/widgets/health_ring.dart';

class StartupAnimation extends ConsumerStatefulWidget {
  const StartupAnimation({super.key});

  @override
  ConsumerState<StartupAnimation> createState() => _StartupAnimationState();
}

class _StartupAnimationState extends ConsumerState<StartupAnimation>
    with TickerProviderStateMixin {
  late AnimationController _gaugeController;
  late AnimationController _messageController;
  late AnimationController _transformController;
  late AnimationController _fadeController;

  int _currentStep = 0;
  double _gaugeValue = 0;
  String _statusMessage = 'Initializing...';
  bool _isComplete = false;

  final List<String> _messages = [
    'Initializing...',
    'Secure connection established...',
    'Authenticating...',
    'Server detected...',
    'Docker detected...',
    'Loading containers...',
    'Fetching metrics...',
    'Mission Control Ready',
  ];

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _transformController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _messages.length; i++) {
      if (!mounted) break;

      setState(() {
        _currentStep = i;
        _statusMessage = _messages[i];
      });

      _messageController.forward(from: 0);

      final targetValue = (i / (_messages.length - 1)) * 100;
      _gaugeValue = targetValue;
      _gaugeController.forward(from: 0);

      await Future.delayed(const Duration(milliseconds: 150));
    }

    if (mounted) {
      setState(() => _isComplete = true);
      _transformController.forward(from: 0);
      _fadeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    _messageController.dispose();
    _transformController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isComplete) ...[
                  _buildGauge(theme),
                  const SizedBox(height: 32),
                  _buildStatusMessage(),
                ] else ...[
                  _buildHealthCard(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGauge(ThemeData theme) {
    return AnimatedBuilder(
      animation: _gaugeController,
      builder: (context, child) {
        return HealthRing(
          score: _gaugeValue,
          size: 180,
          strokeWidth: 12,
        );
      },
    );
  }

  Widget _buildStatusMessage() {
    return AnimatedBuilder(
      animation: _messageController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _messageController,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard(ThemeData theme) {
    return AnimatedBuilder(
      animation: _transformController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + _transformController.value * 0.2,
          child: FadeTransition(
            opacity: _fadeController,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HealthRing(score: 0, size: 140, strokeWidth: 10),
            const SizedBox(height: 16),
            Text(
              'Mission Control Ready',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All systems operational',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}