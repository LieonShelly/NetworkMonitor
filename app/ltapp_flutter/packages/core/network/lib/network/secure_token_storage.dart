import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network_core/token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions.defaultOptions,
  );
  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _kAccessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _kRefreshTokenKey);
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _storage.write(key: _kAccessTokenKey, value: accessToken),
      _storage.write(key: _kAccessTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
