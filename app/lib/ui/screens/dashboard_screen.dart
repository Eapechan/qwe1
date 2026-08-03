import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qwe1/domain/entities/server.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/widgets/server_card.dart';
import 'package:qwe1/ui/widgets/empty_state.dart';
import 'package:qwe1/ui/widgets/skeleton_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final serversAsync = ref.watch(serverListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: serversAsync.when(
        data: (servers) {
          if (servers.isEmpty) {
            return EmptyState(
              icon: Icons.dns_rounded,
              title: 'No servers yet',
              message: 'Add your first server to get started',
              actionLabel: 'Add Server',
              onAction: () => context.push('/add-server'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(serverListProvider.notifier).loadServers();
              await ref.read(serverListProvider.notifier).refreshStatuses();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: servers.length + 1,
              itemBuilder: (context, index) {
                if (index < servers.length) {
                  return _AnimatedServerCard(
                    index: index,
                    server: servers[index],
                    onTap: () => context.push('/server/${servers[index].id}'),
                    onLongPress: () => _showServerActions(context, ref, servers[index]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 6,
          itemBuilder: (context, index) => const SkeletonCard(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: context.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: context.danger,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.onSurfaceMuted,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(serverListProvider.notifier).loadServers(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-server'),
        child: const Icon(Icons.add_rounded),
      ).animate(delay: 200.ms).scale(begin: Offset(0, 0), end: Offset.zero),
    );
  }

  void _showServerActions(BuildContext context, WidgetRef ref, Server server) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit Server'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                server.readOnly ? Icons.lock_rounded : Icons.lock_open_rounded,
              ),
              title: Text(server.readOnly ? 'Disable Read-only' : 'Enable Read-only'),
              onTap: () {
                Navigator.pop(context);
                ref.read(serverListProvider.notifier).updateServer(
                      server.copyWith(readOnly: !server.readOnly),
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: context.danger),
              title: Text(
                'Remove Server',
                style: TextStyle(color: context.danger),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, server);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ).animate().slide(begin: const Offset(0, 1), end: Offset.zero, duration: 200.ms),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Server server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Server'),
        content: Text('Remove "${server.name}"? This will revoke access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(serverListProvider.notifier).deleteServer(server.id);
            },
            child: Text(
              'Remove',
              style: TextStyle(color: context.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedServerCard extends StatelessWidget {
  const _AnimatedServerCard({
    required this.index,
    required this.server,
    required this.onTap,
    required this.onLongPress,
  });

  final int index;
  final Server server;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return ServerCard(
      server: server,
      onTap: onTap,
      onLongPress: onLongPress,
    ).animate(
      delay: Duration(milliseconds: 50 * index),
    ).fadeIn(duration: 300.ms).slide(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
          duration: 300.ms,
        );
  }
}