import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/theme/app_typography.dart';
import 'package:qwe1/ui/widgets/animated_background.dart';
import 'package:qwe1/ui/widgets/health_ring.dart';

class StartupAnimation extends StatefulWidget {
  const StartupAnimation({super.key});

  @override
  State<StartupAnimation> createState() => _StartupAnimationState();
}

class _StartupAnimationState extends State<StartupAnimation>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _messageController;
  int _currentStep = 0;

  final _messages = const [
    'Initializing secure session...',
    'Authenticating...',
    'Secure channel established...',
    'Server detected...',
    'Docker daemon detected...',
    'Synchronizing containers...',
    'Loading live metrics...',
    'Mission Control Ready',
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _messages.length; i++) {
      if (!mounted) return;
      setState(() => _currentStep = i);
      _messageController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_currentStep + 1) / _messages.length;

    return Scaffold(
      backgroundColor: context.background,
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Breathing logo
                AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return Container(
                      width: 80 + (_breathingController.value * 15),
                      height: 80 + (_breathingController.value * 15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary
                                .withOpacity(0.15 + _breathingController.value * 0.1),
                            theme.colorScheme.primary.withOpacity(0.02),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(
                              0.08 + _breathingController.value * 0.08,
                            ),
                            blurRadius: 40,
                            spreadRadius: _breathingController.value * 8,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.dns_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Progress ring
                HealthRing(score: progress * 100, size: 120, strokeWidth: 8),
                const SizedBox(height: 40),

                // Status message
                AnimatedBuilder(
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
                      _messages[_currentStep],
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: context.onSurfaceMuted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
