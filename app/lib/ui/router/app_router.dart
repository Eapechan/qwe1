import 'package:flutter/material.dart';
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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/add-server',
        builder: (context, state) => const AddServerScreen(),
      ),
      GoRoute(
        path: '/server/:serverId',
        builder: (context, state) => ServerDetailScreen(
          serverId: state.pathParameters['serverId']!,
        ),
      ),
      GoRoute(
        path: '/server/:serverId/containers',
        builder: (context, state) => ContainerListScreen(
          serverId: state.pathParameters['serverId']!,
        ),
      ),
      GoRoute(
        path: '/server/:serverId/containers/:containerId',
        builder: (context, state) => ContainerDetailScreen(
          serverId: state.pathParameters['serverId']!,
          containerId: state.pathParameters['containerId']!,
        ),
      ),
      GoRoute(
        path: '/server/:serverId/terminal',
        builder: (context, state) => TerminalScreen(
          serverId: state.pathParameters['serverId']!,
        ),
      ),
      GoRoute(
        path: '/server/:serverId/files',
        builder: (context, state) {
          final path = state.uri.queryParameters['path'] ?? '/';
          return FileBrowserScreen(
            serverId: state.pathParameters['serverId']!,
            initialPath: path,
          );
        },
      ),
      GoRoute(
        path: '/server/:serverId/alerts',
        builder: (context, state) => AlertsScreen(
          serverId: state.pathParameters['serverId']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
