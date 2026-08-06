import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/ui/screens/dashboard_screen.dart';
import 'package:qwe1/ui/screens/server_detail_screen.dart';
import 'package:qwe1/ui/screens/add_server_screen.dart';
import 'package:qwe1/ui/screens/container_list_screen.dart';
import 'package:qwe1/ui/screens/container_detail_screen.dart';
import 'package:qwe1/ui/screens/terminal_screen.dart';
import 'package:qwe1/ui/screens/file_browser_screen.dart';
import 'package:qwe1/ui/screens/alerts_screen.dart';
import 'package:qwe1/ui/screens/settings_screen.dart';
import 'package:qwe1/ui/screens/onboarding_screen.dart';
import 'package:qwe1/ui/screens/start_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const StartScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child
                  .animate()
                  .fadeIn(duration: 200.ms, curve: Curves.easeOutCubic);
            },
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/add-server',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AddServerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/server/:serverId',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ServerDetailScreen(
              serverId: state.pathParameters['serverId']!,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/server/:serverId/containers',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ContainerListScreen(
              serverId: state.pathParameters['serverId']!,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/server/:serverId/containers/:containerId',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: ContainerDetailScreen(
              serverId: state.pathParameters['serverId']!,
              containerId: state.pathParameters['containerId']!,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/server/:serverId/terminal',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: TerminalScreen(
              serverId: state.pathParameters['serverId']!,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/server/:serverId/files',
        pageBuilder: (context, state) {
          final path = state.uri.queryParameters['path'] ?? '/';
          return CustomTransitionPage(
            key: state.pageKey,
            child: FileBrowserScreen(
              serverId: state.pathParameters['serverId']!,
              initialPath: path,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/server/:serverId/alerts',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: AlertsScreen(
              serverId: state.pathParameters['serverId']!,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});