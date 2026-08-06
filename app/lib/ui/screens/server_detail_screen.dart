import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/domain/entities/metrics.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/theme/app_typography.dart';
import 'package:qwe1/ui/widgets/animated_card.dart';
import 'package:qwe1/ui/widgets/metric_card.dart';
import 'package:qwe1/ui/widgets/pulse_indicator.dart';
import 'package:qwe1/ui/widgets/progress_ring.dart';
import 'package:qwe1/ui/widgets/animated_value.dart';
import 'package:qwe1/core/utils/units.dart';

class ServerDetailScreen extends ConsumerWidget {
  const ServerDetailScreen({super.key, required this.serverId});

  final String serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverAsync = ref.watch(serverProvider(serverId));
    final metricsAsync = ref.watch(serverMetricsProvider(serverId));

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: serverAsync.when(
          data: (server) => Text(server.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
              _buildServerHeader(context, server),
              const SizedBox(height: 20),
              metricsAsync.when(
                data: (metrics) => _buildMetricsSection(context, metrics),
                loading: () => _buildMetricsLoading(),
                error: (error, _) => _buildMetricsError(context, ref, error),
              ),
              const SizedBox(height: 20),
              _buildQuickActions(context),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: context.danger),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerHeader(BuildContext context, server) {
    final isOnline = server.status.toLowerCase() == 'online' ||
        server.status.toLowerCase() == 'connected';

    return AnimatedCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isOnline
                  ? context.success.withOpacity(0.05)
                  : context.danger.withOpacity(0.05),
              isOnline
                  ? context.success.withOpacity(0.02)
                  : context.danger.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isOnline ? context.success : context.danger).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PulseIndicator(
                  status: server.status,
                  size: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: AppTypography.displaySmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        server.agentUrl,
                        style: AppTypography.bodySmall(context),
                      ),
                    ],
                  ),
                ),
                if (server.readOnly)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Read-only',
                      style: AppTypography.labelSmall(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(context, 'Uptime', 'Up'),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall(context),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, HostMetrics metrics) {
    final host = metrics.host;

    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Metrics',
              style: AppTypography.headingSmall(context),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: [
                MetricCard(
                  label: 'CPU',
                  value: Units.cpu(host.cpu.percent),
                  icon: Icons.speed_rounded,
                  color: context.statusColor(
                    host.cpu.percent >= 90 ? 'critical' : 'healthy',
                  ),
                  progress: host.cpu.percent / 100,
                ),
                MetricCard(
                  label: 'Memory',
                  value: Units.memoryPercent(host.memory.percent),
                  icon: Icons.memory_rounded,
                  color: context.statusColor(
                    host.memory.percent >= 90 ? 'critical' : 'healthy',
                  ),
                  progress: host.memory.percent / 100,
                ),
                MetricCard(
                  label: 'Storage',
                  value: host.disk.isNotEmpty
                      ? Units.diskPercent(host.disk.first.percent)
                      : '-',
                  icon: Icons.storage_rounded,
                  color: host.disk.isNotEmpty
                      ? context.statusColor(
                          host.disk.first.percent >= 90 ? 'critical' : 'healthy',
                        )
                      : context.onSurfaceMuted,
                  progress: host.disk.isNotEmpty
                      ? host.disk.first.percent / 100
                      : 0,
                ),
                MetricCard(
                  label: 'Temperature',
                  value: host.sensors.isNotEmpty
                      ? Units.temperature(host.sensors.first.celsius)
                      : '-',
                  icon: Icons.thermostat_rounded,
                  color: host.sensors.isNotEmpty
                      ? context.statusColor(
                          host.sensors.first.celsius >= 75
                              ? 'critical'
                              : host.sensors.first.celsius >= 60
                                  ? 'warning'
                                  : 'healthy',
                        )
                      : context.onSurfaceMuted,
                  progress: host.sensors.isNotEmpty
                      ? (host.sensors.first.celsius / 100).clamp(0.0, 1.0)
                      : 0,
                ),
                MetricCard(
                  label: 'Network ↓',
                  value: Units.network(host.network.rxBytesPerSec),
                  icon: Icons.south_rounded,
                  color: context.info,
                  progress: 0,
                ),
                MetricCard(
                  label: 'Network ↑',
                  value: Units.network(host.network.txBytesPerSec),
                  icon: Icons.north_rounded,
                  color: context.info,
                  progress: 0,
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildMetricsError(
    BuildContext context,
    WidgetRef ref,
    Object error,
  ) {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: context.onSurfaceMuted),
            const SizedBox(height: 8),
            Text(
              'Unable to load metrics',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(context).copyWith(
                color: context.onSurfaceMuted.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.invalidate(serverMetricsProvider(serverId));
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTypography.headingSmall(context),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.inventory_2_rounded,
                  label: 'Containers',
                  color: const Color(0xFF10B981),
                  onTap: () => context.push('/server/$serverId/containers'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.terminal_rounded,
                  label: 'Terminal',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.push('/server/$serverId/terminal'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.folder_rounded,
                  label: 'Files',
                  color: const Color(0xFFF59E0B),
                  onTap: () => context.push('/server/$serverId/files'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.notifications_rounded,
                  label: 'Alerts',
                  color: const Color(0xFFEF4444),
                  onTap: () => context.push('/server/$serverId/alerts'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTypography.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}