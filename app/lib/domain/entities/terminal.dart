import 'package:freezed_annotation/freezed_annotation.dart';

part 'terminal.freezed.dart';

@freezed
class TerminalSession with _$TerminalSession {
  const factory TerminalSession({
    required String sessionId,
    required String serverId,
    @Default('') String title,
    @Default(false) bool isActive,
    DateTime? lastActiveAt,
  }) = _TerminalSession;
}
