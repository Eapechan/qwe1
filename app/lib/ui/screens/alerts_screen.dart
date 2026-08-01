import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/alert.dart';
import 'package:qwe1/state/alerts/alert_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/widgets/alert_card.dart';
import 'package:qwe1/ui/widgets/empty_state.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key, required this.serverId});

  final String serverId;

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertSeverity? _severityFilter;
  bool _showAcked = true;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertListProvider(widget.serverId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _showAcked = value == 'all';
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    if (_showAcked) Icon(Icons.check_rounded, size: 16, color: context.primary),
                    if (_showAcked) const SizedBox(width: 8),
                    const Text('Show All'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unacked',
                child: Row(
                  children: [
                    if (!_showAcked) Icon(Icons.check_rounded, size: 16, color: context.primary),
                    if (!_showAcked) const SizedBox(width: 8),
                    const Text('Unacknowledged Only'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Critical', AlertSeverity.critical),
                const SizedBox(width: 8),
                _buildFilterChip('Warning', AlertSeverity.warning),
                const SizedBox(width: 8),
                _buildFilterChip('Info', AlertSeverity.info),
              ],
            ),
          ),

          // Alert list
          Expanded(
            child: alertsAsync.when(
              data: (alerts) {
                var filtered = alerts.where((a) {
                  final matchesSeverity = _severityFilter == null || a.severity == _severityFilter;
                  final matchesAcked = _showAcked || !a.acked;
                  return matchesSeverity && matchesAcked;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.notifications_rounded,
                    title: 'No alerts',
                    message: _severityFilter == null
                        ? 'All clear! No alerts at this time.'
                        : 'No ${_severityFilter!.name} alerts',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(alertListProvider(widget.serverId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final alert = filtered[index];
                      return AlertCard(
                        alert: alert,
                        onAcknowledge: alert.acked
                            ? null
                            : () => ref
                                .read(alertListProvider(widget.serverId).notifier)
                                .acknowledgeAlert(alert.id),
                      );
                    },
                  ),
                );
              },
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AlertSeverity? severity) {
    final isSelected = _severityFilter == severity;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _severityFilter = severity),
      selectedColor: context.primary,
      checkmarkColor: context.onPrimary,
      labelStyle: TextStyle(
        color: isSelected
            ? context.onPrimary
            : context.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
