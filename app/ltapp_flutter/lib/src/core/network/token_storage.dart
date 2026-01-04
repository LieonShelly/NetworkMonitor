abstract interface class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens(String asscessToken, String refreshToken);
  Future<void> clear();
}
