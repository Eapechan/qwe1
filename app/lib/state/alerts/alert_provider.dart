import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/alert.dart';
import 'package:qwe1/domain/repositories/alert_repository.dart';

// Alert list provider
final alertListProvider = StateNotifierProvider.family<AlertListNotifier, AsyncValue<List<Alert>>, String>((ref, serverId) {
  return AlertListNotifier(ref, serverId);
});

class AlertListNotifier extends StateNotifier<AsyncValue<List<Alert>>> {
  AlertListNotifier(this.ref, this.serverId) : super(const AsyncValue.loading()) {
    loadAlerts();
  }

  final Ref ref;
  final String serverId;

  Future<void> loadAlerts() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(alertRepositoryProvider);
      final alerts = await repository.getAlerts(serverId);
      state = AsyncValue.data(alerts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    try {
      final repository = ref.read(alertRepositoryProvider);
      await repository.acknowledgeAlert(serverId, alertId);
      await loadAlerts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Alert threshold provider
final alertThresholdProvider = FutureProvider.family<AlertThreshold, String>((ref, serverId) async {
  final repository = ref.watch(alertRepositoryProvider);
  return repository.getThresholds(serverId);
});

// Alert stream provider
final alertStreamProvider = StreamProvider.family<Alert, String>((ref, serverId) {
  final repository = ref.watch(alertRepositoryProvider);
  return repository.watchAlerts(serverId);
});

// Unacknowledged alert count provider
final unacknowledgedAlertCountProvider = Provider.family<int, String>((ref, serverId) {
  final alerts = ref.watch(alertListProvider(serverId));
  return alerts.when(
    data: (list) => list.where((a) => !a.acked).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Global unacknowledged alert count
final globalUnacknowledgedAlertCountProvider = Provider<int>((ref) {
  // This would aggregate across all servers
  return 0;
});

// Alert repository provider (placeholder)
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  throw UnimplementedError('Alert repository not initialized');
});
