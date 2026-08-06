import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/widgets/animated_background.dart';
import 'package:qwe1/ui/widgets/health_ring.dart';
import 'package:qwe1/ui/widgets/startup_animation.dart';
import 'package:qwe1/ui/widgets/touch_feedback.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _glowController;
  late AnimationController _rippleController;
  bool _isPressed = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onStartTap() {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);

    _buttonController.forward(from: 0);
    _glowController.forward(from: 0);
    _rippleController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        ref.read(serverListProvider.notifier).loadServers();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const StartupAnimation(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
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
                const SizedBox(height: 60),
                _buildLogo(theme),
                const SizedBox(height: 80),
                _buildStartButton(theme),
                const SizedBox(height: 32),
                _buildRippleEffect(),
                const SizedBox(height: 60),
                _buildStatusText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 80 + (_glowController.value * 40),
          height: 80 + (_glowController.value * 40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.2),
                theme.colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(
                  0.1 + _glowController.value * 0.15,
                ),
                blurRadius: 30 + _glowController.value * 20,
                spreadRadius: _glowController.value * 10,
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
    ).animate().scale(begin: const Offset(0.8, 0.8), end: Offset.one, duration: 600.ms);
  }

  Widget _buildStartButton(ThemeData theme) {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (1.0 - 0.96) * _buttonController.value,
          child: child,
        );
      },
      child: TouchFeedback(
        onTap: _onStartTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Start',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Container(
          width: 200 + _rippleController.value * 200,
          height: 200 + _rippleController.value * 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(
                    0.3 * (1 - _rippleController.value),
                  ),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusText() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Opacity(
          opacity: _rippleController.value,
          child: child,
        );
      },
      child: const Text(
        'Initializing...',
        style: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}