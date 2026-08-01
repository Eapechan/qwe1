import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/ui/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconScales;
  late List<Animation<double>> _iconRotations;

  final _pages = [
    _OnboardingData(
      icon: Icons.dns_rounded,
      title: 'Self-Hosted Servers',
      description: 'Manage your Linux servers directly from your phone. No cloud, no accounts, no subscriptions.',
      gradientColors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
    ),
    _OnboardingData(
      icon: Icons.speed_rounded,
      title: 'Real-Time Monitoring',
      description: 'Monitor CPU, RAM, disk, network, and temperature in real-time with live updating charts.',
      gradientColors: [const Color(0xFF10B981), const Color(0xFF06B6D4)],
    ),
    _OnboardingData(
      icon: Icons.inventory_2_rounded,
      title: 'Docker Management',
      description: 'List, start, stop, restart, and view logs for all your Docker containers.',
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
    ),
    _OnboardingData(
      icon: Icons.terminal_rounded,
      title: 'Interactive Terminal',
      description: 'Full PTY terminal sessions from your phone with all the keys you need.',
      gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
    ),
    _OnboardingData(
      icon: Icons.folder_rounded,
      title: 'File Browser',
      description: 'Browse, preview, upload, and download files on your server.',
      gradientColors: [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconControllers = List.generate(
      _pages.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _iconScales = List.generate(
      _pages.length,
      (index) => Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _iconControllers[index], curve: Curves.elasticOut),
      ),
    );
    _iconRotations = List.generate(
      _pages.length,
      (index) => Tween<double>(begin: -0.2, end: 0.0).animate(
        CurvedAnimation(parent: _iconControllers[index], curve: Curves.easeOutBack),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iconControllers[0].forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: context.onSurfaceMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _iconControllers[index].forward(from: 0.0);
                },
                itemBuilder: (context, index) => _buildPage(context, index),
              ),
            ),
            _buildIndicators(context),
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, int index) {
    final page = _pages[index];
    final iconScale = _iconScales[index];
    final iconRotation = _iconRotations[index];

    return AnimatedBuilder(
      animation: Listenable.merge([iconScale, iconRotation]),
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: iconScale.value,
                child: Transform.rotate(
                  angle: iconRotation.value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: page.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: page.gradientColors.first.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Icon(
                      page.icon,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                page.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                page.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.onSurfaceMuted,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndicators(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentPage == index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            if (!isLast) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            } else {
              context.go('/');
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              isLast ? 'Get Started' : 'Next',
              key: ValueKey(isLast),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;
}
