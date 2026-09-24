import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistencia segura de tokens (Keychain en iOS, Keystore en Android).
class TokenStorage {
  static const _kAccess = 'agecare_access_token';
  static const _kRefresh = 'agecare_refresh_token';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<bool> get hasSession async => (await refreshToken) != null;

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
