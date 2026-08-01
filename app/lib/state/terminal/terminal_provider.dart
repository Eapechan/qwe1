import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/terminal.dart';
import 'package:qwe1/domain/repositories/terminal_repository.dart';

// Terminal sessions provider
final terminalSessionsProvider = StateNotifierProvider.family<TerminalSessionsNotifier, AsyncValue<List<TerminalSession>>, String>((ref, serverId) {
  return TerminalSessionsNotifier(ref, serverId);
});

class TerminalSessionsNotifier extends StateNotifier<AsyncValue<List<TerminalSession>>> {
  TerminalSessionsNotifier(this.ref, this.serverId) : super(const AsyncValue.loading()) {
    loadSessions();
  }

  final Ref ref;
  final String serverId;

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(terminalRepositoryProvider);
      final sessions = await repository.getSessions(serverId);
      state = AsyncValue.data(sessions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<TerminalSession> createSession() async {
    try {
      final repository = ref.read(terminalRepositoryProvider);
      final session = await repository.createSession(serverId);
      await loadSessions();
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      final repository = ref.read(terminalRepositoryProvider);
      await repository.deleteSession(serverId, sessionId);
      await loadSessions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Active terminal session provider
final activeTerminalProvider = StateProvider<TerminalSession?>((ref) => null);

// Terminal output stream provider
final terminalOutputProvider = StreamProvider.family<Uint8List, ({String serverId, String sessionId})>((ref, params) {
  final repository = ref.watch(terminalRepositoryProvider);
  return repository.getOutputStream(params.serverId, params.sessionId);
});

// Terminal repository provider (placeholder)
final terminalRepositoryProvider = Provider<TerminalRepository>((ref) {
  throw UnimplementedError('Terminal repository not initialized');
});
