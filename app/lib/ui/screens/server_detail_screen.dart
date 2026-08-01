import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/domain/entities/metrics.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/ui/widgets/metric_card.dart';
import 'package:qwe1/ui/widgets/status_indicator.dart';

class ServerDetailScreen extends ConsumerWidget {
  const ServerDetailScreen({super.key, required this.serverId});

  final String serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverAsync = ref.watch(serverProvider(serverId));
    final metricsAsync = ref.watch(serverMetricsProvider(serverId));

    return Scaffold(
      appBar: AppBar(
        title: serverAsync.when(
          data: (server) => Text(server.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(serverProvider(serverId));
              ref.invalidate(serverMetricsProvider(serverId));
            },
          ),
        ],
      ),
      body: serverAsync.when(
        data: (server) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(serverProvider(serverId));
            ref.invalidate(serverMetricsProvider(serverId));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Server status header
              _buildServerHeader(context, server),
              const SizedBox(height: 24),

              // Live metrics
              metricsAsync.when(
                data: (metrics) => _buildMetricsSection(context, metrics),
                loading: () => _buildMetricsLoading(),
                error: (error, _) => _buildMetricsError(error),
              ),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(context),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerHeader(BuildContext context, server) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusIndicator(status: server.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        server.agentUrl,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (server.readOnly)
                  Chip(
                    label: const Text('Read-only'),
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(context, 'Uptime', _formatUptime(server)),
                const SizedBox(width: 8),
                _buildInfoChip(context, 'Agent', server.agentVersion),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, HostMetrics metrics) {
    final host = metrics.host;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Metrics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            MetricCard(
              label: 'CPU',
              value: '${host.cpu.percent.toStringAsFixed(1)}%',
              icon: Icons.speed,
              color: _getMetricColor(host.cpu.percent),
            ),
            MetricCard(
              label: 'Memory',
              value: '${host.memory.percent.toStringAsFixed(1)}%',
              icon: Icons.memory,
              color: _getMetricColor(host.memory.percent),
            ),
            MetricCard(
              label: 'Disk',
              value: host.disk.isNotEmpty
                  ? '${host.disk.first.percent.toStringAsFixed(1)}%'
                  : '-',
              icon: Icons.storage,
              color: host.disk.isNotEmpty
                  ? _getMetricColor(host.disk.first.percent)
                  : Colors.grey,
            ),
            MetricCard(
              label: 'Temperature',
              value: host.sensors.isNotEmpty
                  ? '${host.sensors.first.celsius.toStringAsFixed(1)}°C'
                  : '-',
              icon: Icons.thermostat,
              color: host.sensors.isNotEmpty
                  ? _getTempColor(host.sensors.first.celsius)
                  : Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMetricsError(Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Unable to load metrics: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              context,
              icon: Icons.inventory_2,
              label: 'Containers',
              onTap: () => context.push('/server/$serverId/containers'),
            ),
            _buildActionCard(
              context,
              icon: Icons.terminal,
              label: 'Terminal',
              onTap: () => context.push('/server/$serverId/terminal'),
            ),
            _buildActionCard(
              context,
              icon: Icons.folder,
              label: 'Files',
              onTap: () => context.push('/server/$serverId/files'),
            ),
            _buildActionCard(
              context,
              icon: Icons.notifications,
              label: 'Alerts',
              onTap: () => context.push('/server/$serverId/alerts'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMetricColor(double percent) {
    if (percent >= 90) return Colors.red;
    if (percent >= 70) return Colors.orange;
    return Colors.green;
  }

  Color _getTempColor(double celsius) {
    if (celsius >= 75) return Colors.red;
    if (celsius >= 60) return Colors.orange;
    return Colors.green;
  }

  String _formatUptime(server) {
    // TODO: Implement proper uptime formatting
    return 'Up';
  }
}
