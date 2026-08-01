abstract class AuthRepository {
  Future<AuthResult> enroll({
    required String agentUrl,
    required String enrollmentToken,
    required String deviceName,
  });
  Future<AuthResult> refresh(String refreshToken);
  Future<void> revoke(String serverId);
  Future<DeviceInfo> getDeviceInfo(String serverId);
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final String serverFingerprint;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.serverFingerprint,
  });
}

class DeviceInfo {
  final String deviceId;
  final String serverName;
  final String agentVersion;
  final Map<String, dynamic> capabilities;
  final bool readOnly;

  DeviceInfo({
    required this.deviceId,
    required this.serverName,
    required this.agentVersion,
    required this.capabilities,
    required this.readOnly,
  });
}
