import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qwe1/domain/entities/server.dart';
import 'package:qwe1/domain/entities/metrics.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/theme/app_typography.dart';
import 'package:qwe1/ui/widgets/animated_background.dart';
import 'package:qwe1/ui/widgets/animated_card.dart';
import 'package:qwe1/ui/widgets/health_ring.dart';
import 'package:qwe1/ui/widgets/pulse_indicator.dart';
import 'package:qwe1/ui/widgets/progress_ring.dart';
import 'package:qwe1/ui/widgets/animated_value.dart';
import 'package:qwe1/ui/widgets/sparkline.dart';
import 'package:qwe1/core/utils/health_score.dart';
import 'package:qwe1/core/utils/units.dart';
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
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Mission Control'),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: servers.length,
              itemBuilder: (context, index) {
                return _ServerCard(
                  index: index,
                  server: servers[index],
                  onTap: () => context.push('/server/${servers[index].id}'),
                );
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: 3,
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
                style: theme.textTheme.headlineMedium?.copyWith(
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
      ).animate(delay: 200.ms).scale(begin: const Offset(0, 0), end: Offset.zero),
    );
  }
}

class _ServerCard extends ConsumerWidget {
  final int index;
  final Server server;
  final VoidCallback onTap;

  const _ServerCard({
    required this.index,
    required this.server,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(serverMetricsProvider(server.id));
    final isOnline = server.status.toLowerCase() == 'online' ||
        server.status.toLowerCase() == 'connected';

    return AnimatedCard(
      delay: index * 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Hero section
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.surface,
                      context.surfaceVariant.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: context.border.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Health Ring
                    HealthRing(
                      score: 75,
                      size: 80,
                      strokeWidth: 8,
                    ),
                    const SizedBox(width: 16),
                    // Server info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PulseIndicator(
                                status: server.status,
                                size: 10,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  server.name,
                                  style: AppTypography.headingMedium(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            server.agentUrl,
                            style: AppTypography.bodySmall(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip(context, 'Status', server.status),
                              const SizedBox(width: 8),
                              if (server.agentVersion.isNotEmpty)
                                _buildInfoChip(
                                  context,
                                  'Agent',
                                  server.agentVersion,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Metrics section
            if (server.status.toLowerCase() == 'online' ||
                server.status.toLowerCase() == 'connected') ...[
              const SizedBox(height: 16),
              metricsAsync.when(
                data: (metrics) {
                  final host = metrics.host;
                  return _buildMetricsRow(context, host);
                },
                loading: () => const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, HostInfo host) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'CPU',
            value: Units.cpu(host.cpu.percent),
            icon: Icons.speed_rounded,
            color: context.statusColor(
              host.cpu.percent >= 90 ? 'critical' : 'healthy',
            ),
            progress: host.cpu.percent / 100,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: 'RAM',
            value: Units.memoryPercent(host.memory.percent),
            icon: Icons.memory_rounded,
            color: context.statusColor(
              host.memory.percent >= 90 ? 'critical' : 'healthy',
            ),
            progress: host.memory.percent / 100,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: 'Disk',
            value: host.disk.isNotEmpty
                ? Units.diskPercent(host.disk.first.percent)
                : '-',
            icon: Icons.storage_rounded,
            color: host.disk.isNotEmpty
                ? context.statusColor(
                    host.disk.first.percent >= 90 ? 'critical' : 'healthy',
                  )
                : context.onSurfaceMuted,
            progress: host.disk.isNotEmpty ? host.disk.first.percent / 100 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: AppTypography.labelSmall(context),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double progress;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedValue(
            targetValue: double.tryParse(value.replaceAll('%', '')) ?? 0,
            formatter: (v) => '${v.toStringAsFixed(1)}%',
            style: AppTypography.numberSmall(context).copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          ProgressRing(
            progress: progress,
            size: 36,
            strokeWidth: 3,
            color: color,
          ),
        ],
      ),
    );
  }
}