import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/state/docker/container_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/theme/app_typography.dart';
import 'package:qwe1/ui/widgets/pulse_indicator.dart';

class ContainerDetailScreen extends ConsumerStatefulWidget {
  const ContainerDetailScreen({
    super.key,
    required this.serverId,
    required this.containerId,
  });

  final String serverId;
  final String containerId;

  @override
  ConsumerState<ContainerDetailScreen> createState() =>
      _ContainerDetailScreenState();
}

class _ContainerDetailScreenState extends ConsumerState<ContainerDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final containerAsync = ref.watch(
      containerProvider(
        (serverId: widget.serverId, containerId: widget.containerId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: containerAsync.when(
          data: (c) =>
              Text(c.name.isNotEmpty ? c.name : c.id.substring(0, 12)),
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
                    Icon(Icons.stop_circle_rounded,
                        size: 20, color: Colors.orange),
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
            onSelected: (value) => _handleMenuAction(value),
          ),
        ],
      ),
      body: containerAsync.when(
        data: (container) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeroCard(context, container),
            const SizedBox(height: 16),
            _buildActionButtons(context),
            const SizedBox(height: 16),
            _buildDetailsSection(context, container),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'inspect':
        _showSnackBar('Inspect coming soon');
        break;
      case 'logs':
        _showSnackBar('Container logs coming soon');
        break;
      case 'kill':
        _killContainer();
        break;
      case 'remove':
        _showRemoveDialog();
        break;
    }
  }

  void _killContainer() {
    ref
        .read(
          containerListProvider(widget.serverId).notifier,
        )
        .killContainer(widget.containerId);
    _showSnackBar('Killing container...');
  }

  void _showRemoveDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Container'),
        content: const Text(
          'This will force-remove the container. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(
                    containerListProvider(widget.serverId).notifier,
                  )
                  .removeContainer(widget.containerId);
              _showSnackBar('Removing container...');
              Navigator.of(context).pop();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildHeroCard(
      BuildContext context, dynamic container) {
    final isRunning = container.state.toLowerCase() == 'running';
    final stateColor = _getStateColor(context, container.state);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stateColor.withOpacity(0.08),
            stateColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: stateColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulseIndicator(
                status: isRunning ? 'online' : 'offline',
                size: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      container.name.isNotEmpty
                          ? container.name
                          : container.id.substring(0, 12),
                      style: AppTypography.headingMedium(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      container.image,
                      style: AppTypography.bodySmall(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  container.state.toUpperCase(),
                  style: TextStyle(
                    color: stateColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (container.ports.isNotEmpty) ...[
            Text(
              'Ports',
              style: AppTypography.labelMedium(context),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: container.ports.map((p) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${p.host}:${p.container}',
                    style: AppTypography.labelSmall(context).copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDetailItem(context, 'CPU',
                  '${container.cpuPercent.toStringAsFixed(1)}%'),
              const SizedBox(width: 12),
              _buildDetailItem(
                  context, 'Memory', _formatBytes(container.memoryBytes)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.labelSmall(context)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.numberSmall(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(containerListProvider(widget.serverId).notifier)
                  .startContainer(widget.containerId);
              _showSnackBar('Starting container...');
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(containerListProvider(widget.serverId).notifier)
                  .stopContainer(widget.containerId);
              _showSnackBar('Stopping container...');
            },
            icon: const Icon(Icons.stop_rounded, size: 20),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(containerListProvider(widget.serverId).notifier)
                  .restartContainer(widget.containerId);
              _showSnackBar('Restarting container...');
            },
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
            label: const Text('Restart'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, dynamic container) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: AppTypography.headingSmall(context)),
          const SizedBox(height: 12),
          _buildDetailRow(
              context, 'ID', container.id.substring(0, 12)),
          _buildDetailRow(context, 'Name',
              container.name.isNotEmpty ? container.name : '-'),
          _buildDetailRow(context, 'Image', container.image),
          _buildDetailRow(
              context, 'Memory', _formatBytes(container.memoryBytes)),
          _buildDetailRow(
              context, 'CPU', '${container.cpuPercent.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: AppTypography.labelMedium(context)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium(context)
                  .copyWith(fontWeight: FontWeight.w600),
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
