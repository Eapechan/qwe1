import 'package:freezed_annotation/freezed_annotation.dart';

part 'server.freezed.dart';

@freezed
class Server with _$Server {
  const factory Server({
    required String id,
    required String name,
    required String agentUrl,
    @Default('') String groupName,
    @Default(false) bool readOnly,
    @Default('') String fingerprintHash,
    @Default('unknown') String status,
    @Default('') String deviceId,
    DateTime? lastSeenAt,
    required DateTime createdAt,
    @Default('') String agentVersion,
    @Default({}) Map<String, dynamic> capabilities,
  }) = _Server;
}
