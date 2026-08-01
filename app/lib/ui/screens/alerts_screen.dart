import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/alert.dart';
import 'package:qwe1/state/alerts/alert_provider.dart';
import 'package:qwe1/ui/widgets/alert_card.dart';
import 'package:qwe1/ui/widgets/empty_state.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key, required this.serverId});

  final String serverId;

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String _severityFilter = 'all';
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
              const PopupMenuItem(value: 'all', child: Text('Show All')),
              const PopupMenuItem(value: 'unacked', child: Text('Unacknowledged Only')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Critical', 'critical'),
                const SizedBox(width: 8),
                _buildFilterChip('Warning', 'warning'),
                const SizedBox(width: 8),
                _buildFilterChip('Info', 'info'),
              ],
            ),
          ),

          // Alert list
          Expanded(
            child: alertsAsync.when(
              data: (alerts) {
                final filtered = alerts.where((alert) {
                  final matchesSeverity = _severityFilter == 'all' ||
                      alert.severity.name == _severityFilter;

                  final matchesAcked = _showAcked || !alert.acked;

                  return matchesSeverity && matchesAcked;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.notifications_off,
                    title: 'No alerts',
                    message: _severityFilter == 'all'
                        ? 'All quiet. We\'ll alert you when something needs attention.'
                        : 'No $_severityFilter alerts',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final alert = filtered[index];
                    return AlertCard(
                      alert: alert,
                      onAcknowledge: () {
                        ref
                            .read(alertListProvider(widget.serverId).notifier)
                            .acknowledgeAlert(alert.id);
                      },
                    );
                  },
                );
              },
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _severityFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _severityFilter = value;
        });
      },
    );
  }
}
