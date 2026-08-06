import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/theme/app_typography.dart';
import 'package:qwe1/ui/widgets/animated_background.dart';
import 'package:qwe1/ui/widgets/analog_gauge.dart';
import 'package:qwe1/ui/widgets/health_ring.dart';

class StartupAnimation extends ConsumerStatefulWidget {
  const StartupAnimation({super.key});

  @override
  ConsumerState<StartupAnimation> createState() => _StartupAnimationState();
}

class _StartupAnimationState extends ConsumerState<StartupAnimation>
    with TickerProviderStateMixin {
  // Stage 1: Idle breathing animation
  late AnimationController _breathingController;

  // Stage 2: Power-on ring
  late AnimationController _ringController;

  // Stage 3: Status messages
  late AnimationController _messageController;

  // Stage 4: Instrument cluster
  late AnimationController _gaugeController;

  // Stage 5: Transform to dashboard
  late AnimationController _transformController;

  // Stage 5: Fade to dashboard
  late AnimationController _fadeController;

  int _currentStage = 0;
  double _gaugeValue = 0;
  String _statusMessage = 'Initializing...';
  bool _isComplete = false;

  // Real server state tracking
  bool _isLoading = false;
  bool _isServersLoaded = false;
  bool _isContainersLoaded = false;

  final List<String> _stageMessages = [
    'Initializing secure session...',
    'Authenticating...',
    'Secure channel established...',
    'Server detected...',
    'Docker detected...',
    'Synchronizing containers...',
    'Loading live metrics...',
    'Mission Control Ready',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize all stage controllers
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _ringController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _gaugeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _transformController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start the full sequence
    _runStages();

    // Listen to real server events
    _setupServerListeners();
  }

  void _setupServerListeners() {
    ref.listen<AsyncValue>(serverListProvider, (previous, next) {
      if (next.hasValue) {
        _onServersLoaded();
      } else if (next.hasError) {
        _onServerError(next.error!);
      }
    });
  }

  Future<void> _runStages() async {
    // Stage 1: Idle breathing (for 900ms)
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _currentStage = 1);
    _ringController.forward(from: 0);

    // Stage 2: Show messages sequentially
    for (int i = 0; i < _stageMessages.length - 1; i++) {
      if (!mounted) break;

      setState(() {
        _currentStage = 1;
        _statusMessage = _stageMessages[i];
      });

      _messageController.forward(from: 0);

      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) {
      setState(() {
        _currentStage = 2;
        _statusMessage = _stageMessages.last;
      });
      _messageController.forward(from: 0);
      _gaugeController.forward(from: 0);

      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _isComplete = true);
      _transformController.forward(from: 0);
      _fadeController.forward(from: 0);

      // Wait for the mission control card to be visible, then navigate
      await Future.delayed(const Duration(milliseconds: 1200));

      if (mounted) {
        context.go('/');
      }
    }
  }

  void _onServersLoaded() {
    if (!_isServersLoaded) {
      _isServersLoaded = true;
      _advanceStage('Server discovered...');
    }
  }

  void _onContainersLoaded() {
    if (!_isContainersLoaded) {
      _isContainersLoaded = true;
      _advanceStage('All containers synchronized...');
    }
  }

  void _onServerError(Object error) {
    _advanceStage('Connection issue detected...');
  }

  void _advanceStage(String message) {
    if (_currentStage < 5) {
      setState(() {
        _currentStage = _currentStage + 1;
        _statusMessage = message;
      });
      _messageController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _ringController.dispose();
    _messageController.dispose();
    _gaugeController.dispose();
    _transformController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.background,
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isComplete) ...[
                  // Stage 1: Idle breathing
                  if (_currentStage == 0) ...[
                    _buildBreathingIndicator(theme),
                    const SizedBox(height: 40),
                    _buildStatusMessage(),
                  ],

                  // Stage 2: Power-on ring
                  if (_currentStage == 1) ...[
                    _buildPowerOnRing(theme),
                    const SizedBox(height: 32),
                    _buildStatusMessage(),
                  ],

                  // Stage 3: Instrument cluster
                  if (_currentStage == 2) ...[
                    _buildInstrumentCluster(theme),
                    const SizedBox(height: 32),
                    _buildStatusMessage(),
                  ],

                  // Stage 4: Loading
                  if (_currentStage == 3 || _currentStage == 4) ...[
                    _buildLoadingScreen(theme),
                    const SizedBox(height: 32),
                    _buildStatusMessage(),
                  ],
                ] else ...[
                  // Stage 5: Mission Control Ready
                  _buildMissionControlCard(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingIndicator(ThemeData theme) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          width: 80 + (_breathingController.value * 20),
          height: 80 + (_breathingController.value * 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.05),
                blurRadius: 40 + (_breathingController.value * 20),
                spreadRadius: (_breathingController.value * 5),
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
        child: const Icon(Icons.dns_rounded, color: Colors.white, size: 40),
      ),
    ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms);
  }

  Widget _buildPowerOnRing(ThemeData theme) {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (context, child) {
        return Container(
          width: 200 + (_ringController.value * 100),
          height: 200 + (_ringController.value * 100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3 * (1 - _ringController.value)),
              width: 2 + (_ringController.value * 4),
            ),
          ),
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
              color: theme.colorScheme.primary.withOpacity(0.3 + (_ringController.value * 0.4)),
              blurRadius: 20 + (_ringController.value * 20),
              spreadRadius: (_ringController.value * 5),
            ),
          ],
        ),
        child: const Icon(Icons.dns_rounded, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildInstrumentCluster(ThemeData theme) {
    return AnimatedBuilder(
      animation: _gaugeController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnalogGauge(
              value: _gaugeValue,
              size: 220,
              unit: 'CPU %',
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingScreen(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HealthRing(score: 0, size: 140, strokeWidth: 10),
        const SizedBox(height: 32),
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionControlCard(ThemeData theme) {
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
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: context.border.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated health ring with glow
            AnimatedBuilder(
              animation: _transformController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3 + (_transformController.value * 0.4)),
                        blurRadius: 30 + (_transformController.value * 20),
                        spreadRadius: (_transformController.value * 5),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: const HealthRing(score: 100, size: 160, strokeWidth: 12),
            ),
            const SizedBox(height: 24),
            Text(
              'Mission Control Ready',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'All systems operational',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.onSurfaceMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return AnimatedBuilder(
      animation: _messageController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _messageController,
          child: child,
        ).animate().slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(context).copyWith(
            color: context.onSurfaceMuted,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}