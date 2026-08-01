import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/state/docker/container_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/widgets/status_indicator.dart';

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
    final containerAsync = ref.watch(containerProvider((serverId: serverId, containerId: containerId)));

    return Scaffold(
      appBar: AppBar(
        title: containerAsync.when(
          data: (c) => Text(c.name.isNotEmpty ? c.name : c.id.substring(0, 12)),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Container'),
        ),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'inspect',
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Inspect'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logs',
                child: Row(
                  children: [
                    Icon(Icons.article_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('View Logs'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'kill',
                child: Row(
                  children: [
                    Icon(Icons.stop_circle_rounded, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Kill', style: TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              // TODO: Implement inspect/logs navigation
            },
          ),
        ],
      ),
      body: containerAsync.when(
        data: (container) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusCard(context, container),
            const SizedBox(height: 16),
            _buildActionButtons(context, ref),
            const SizedBox(height: 16),
            _buildDetailsSection(context, container),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, container) {
    final stateColor = _getStateColor(context, container.state);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              stateColor.withOpacity(0.06),
              stateColor.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusIndicator(
                  status: container.state.toLowerCase() == 'running' ? 'online' : 'offline',
                  size: 10,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stateColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    container.state.toUpperCase(),
                    style: TextStyle(
                      color: stateColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (container.health.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getHealthColor(context, container.health).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      container.health.toUpperCase(),
                      style: TextStyle(
                        color: _getHealthColor(context, container.health),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Image', container.image),
            if (container.status.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(context, 'Status', container.status),
            ],
            if (container.ports.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(context, 'Ports', container.ports.map((p) => '${p.host}:${p.container}').join(', ')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.onSurfaceMuted,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.stop_rounded, size: 20),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.danger,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
            label: const Text('Restart'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, container) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'ID', container.id.substring(0, 12)),
            _buildDetailRow(context, 'Name', container.name.isNotEmpty ? container.name : '-'),
            _buildDetailRow(context, 'Image', container.image),
            _buildDetailRow(context, 'Memory', _formatBytes(container.memoryBytes)),
            _buildDetailRow(context, 'CPU', '${container.cpuPercent.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.onSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(BuildContext context, String state) {
    switch (state.toLowerCase()) {
      case 'running':
        return context.success;
      case 'exited':
      case 'created':
        return context.onSurfaceMuted;
      case 'paused':
        return context.warning;
      default:
        return context.onSurfaceMuted;
    }
  }

  Color _getHealthColor(BuildContext context, String health) {
    switch (health.toLowerCase()) {
      case 'healthy':
        return context.success;
      case 'unhealthy':
        return context.danger;
      default:
        return context.warning;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
