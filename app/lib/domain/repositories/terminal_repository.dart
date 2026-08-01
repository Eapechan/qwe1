import 'dart:async';
import 'dart:typed_data';

import 'package:qwe1/domain/entities/terminal.dart';

abstract class TerminalRepository {
  Future<TerminalSession> createSession(String serverId, {int cols = 80, int rows = 24});
  Future<void> deleteSession(String serverId, String sessionId);
  Future<List<TerminalSession>> getSessions(String serverId);
  Stream<Uint8List> getOutputStream(String serverId, String sessionId);
  void sendInput(String serverId, String sessionId, Uint8List data);
  void resize(String serverId, String sessionId, int cols, int rows);
}
