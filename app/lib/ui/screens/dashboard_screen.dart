import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/domain/entities/server.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/ui/widgets/server_card.dart';
import 'package:qwe1/ui/widgets/empty_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversAsync = ref.watch(serverListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: serversAsync.when(
        data: (servers) {
          if (servers.isEmpty) {
            return EmptyState(
              icon: Icons.dns_outlined,
              title: 'No servers yet',
              message: 'Add your first server to get started',
              actionLabel: 'Add Server',
              onAction: () => context.push('/add-server'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(serverListProvider.notifier).loadServers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                return ServerCard(
                  server: server,
                  onTap: () => context.push('/server/${server.id}'),
                  onLongPress: () => _showServerActions(context, ref, server),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading servers: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(serverListProvider.notifier).loadServers(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-server'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showServerActions(BuildContext context, WidgetRef ref, Server server) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Server'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.toggle_on),
              title: Text(server.readOnly ? 'Disable Read-only' : 'Enable Read-only'),
              onTap: () {
                Navigator.pop(context);
                ref.read(serverListProvider.notifier).updateServer(
                      server.copyWith(readOnly: !server.readOnly),
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Server', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, server);
              },
            ),
          ],
        ),
      ),
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
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
