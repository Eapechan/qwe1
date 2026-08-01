import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _serverPrefix = 'server_';
  static const _refreshTokenSuffix = '_refresh_token';
  static const _accessTokenSuffix = '_access_token';
  static const _fingerprintSuffix = '_fingerprint';
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _themeModeKey = 'theme_mode';

  // Server tokens
  Future<void> saveRefreshToken(String serverId, String token) async {
    await _storage.write(key: '$_serverPrefix$serverId$_refreshTokenSuffix', value: token);
  }

  Future<String?> getRefreshToken(String serverId) async {
    return _storage.read(key: '$_serverPrefix$serverId$_refreshTokenSuffix');
  }

  Future<void> deleteRefreshToken(String serverId) async {
    await _storage.delete(key: '$_serverPrefix$serverId$_refreshTokenSuffix');
  }

  Future<void> saveAccessToken(String serverId, String token) async {
    await _storage.write(key: '$_serverPrefix$serverId$_accessTokenSuffix', value: token);
  }

  Future<String?> getAccessToken(String serverId) async {
    return _storage.read(key: '$_serverPrefix$serverId$_accessTokenSuffix');
  }

  Future<void> deleteAccessToken(String serverId) async {
    await _storage.delete(key: '$_serverPrefix$serverId$_accessTokenSuffix');
  }

  // Server fingerprint
  Future<void> saveFingerprint(String serverId, String fingerprint) async {
    await _storage.write(
      key: '$_serverPrefix$serverId$_fingerprintSuffix',
      value: fingerprint,
    );
  }

  Future<String?> getFingerprint(String serverId) async {
    return _storage.read(key: '$_serverPrefix$serverId$_fingerprintSuffix');
  }

  Future<void> deleteFingerprint(String serverId) async {
    await _storage.delete(key: '$_serverPrefix$serverId$_fingerprintSuffix');
  }

  // All server tokens
  Future<void> deleteAllServerData(String serverId) async {
    await _storage.delete(key: '$_serverPrefix$serverId$_refreshTokenSuffix');
    await _storage.delete(key: '$_serverPrefix$serverId$_accessTokenSuffix');
    await _storage.delete(key: '$_serverPrefix$serverId$_fingerprintSuffix');
  }

  // App settings
  Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: _themeModeKey, value: mode);
  }

  Future<String?> getThemeMode() async {
    return _storage.read(key: _themeModeKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
