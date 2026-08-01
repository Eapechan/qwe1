import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/container.dart' as domain;
import 'package:qwe1/state/docker/container_provider.dart';

class ContainerDetailScreen extends ConsumerWidget {
  const ContainerDetailScreen({
    super.key,
    required this.serverId,
    required this.containerId,
  });

  final String serverId;
  final String containerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containerAsync = ref.watch(
      containerProvider((serverId: serverId, containerId: containerId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: containerAsync.when(
          data: (container) => Text(container.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Container'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (action) => _handleAction(context, ref, action),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'inspect', child: Text('Inspect')),
              const PopupMenuItem(value: 'logs', child: Text('View Logs')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'kill', child: Text('Kill')),
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: containerAsync.when(
        data: (container) => _buildContent(context, ref, container),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, domain.Container container) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _buildStatusCard(context, container),
          const SizedBox(height: 16),

          // Actions
          _buildActionButtons(context, ref, container),
          const SizedBox(height: 16),

          // Details
          _buildDetailsSection(context, container),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, domain.Container container) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusChip(container.state),
                const SizedBox(width: 8),
                if (container.health.isNotEmpty)
                  _buildHealthChip(container.health),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Image', container.image),
            _buildDetailRow('Status', container.status),
            if (container.ports.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Ports'),
              ...container.ports.map((port) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text('${port.host} -> ${port.container}/${port.protocol}'),
                  )),
            ],
            const SizedBox(height: 8),
            _buildDetailRow('CPU', '${container.cpuPercent.toStringAsFixed(1)}%'),
            _buildDetailRow('Memory', _formatBytes(container.memoryBytes)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String state) {
    Color color;
    switch (state) {
      case 'running':
        color = Colors.green;
        break;
      case 'exited':
        color = Colors.red;
        break;
      case 'paused':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(state.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHealthChip(String health) {
    Color color;
    switch (health) {
      case 'healthy':
        color = Colors.green;
        break;
      case 'unhealthy':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(health.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, domain.Container container) {
    final notifier = ref.read(containerListProvider(serverId).notifier);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: container.state == 'running'
                ? null
                : () => notifier.startContainer(container.id),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: container.state != 'running'
                ? null
                : () => notifier.stopContainer(container.id),
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => notifier.restartContainer(container.id),
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, domain.Container container) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildDetailRow('ID', container.id.substring(0, 12)),
            _buildDetailRow('Name', container.name),
            _buildDetailRow('Image', container.image),
            if (container.createdAt != null)
              _buildDetailRow('Created', container.createdAt.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    final notifier = ref.read(containerListProvider(serverId).notifier);

    switch (action) {
      case 'inspect':
        // TODO: Navigate to inspect screen
        break;
      case 'logs':
        // TODO: Navigate to logs screen
        break;
      case 'kill':
        _showConfirmDialog(
          context,
          title: 'Kill Container',
          message: 'Are you sure you want to kill this container?',
          onConfirm: () => notifier.killContainer(containerId),
        );
        break;
      case 'remove':
        _showConfirmDialog(
          context,
          title: 'Remove Container',
          message: 'This will permanently remove the container.',
          destructive: true,
          onConfirm: () => notifier.removeContainer(containerId),
        );
        break;
    }
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool destructive = false,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                color: destructive ? Colors.red : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
