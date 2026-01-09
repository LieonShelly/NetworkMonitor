import 'package:ltapp_flutter/src/core/network/token_storage.dart';

class MockTokenStorage implements TokenStorage {
  @override
  Future<String?> getAccessToken() async {
    return r"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjbWdyam1tN20wMDAwcHBweHZoZXhuMm1tIiwiYXBwbGVJZCI6IjAwMTc3NC5mYjZiNjFiMjk5MmU0NjgzOGJlZTM0ZTc4MWE2YTExNC4xMDIxIiwidHlwZSI6ImFjY2VzcyIsImlhdCI6MTc2NzkzMTgyNSwiZXhwIjoxNzY4MDE4MjI1fQ.qtFT_HYrH47xqf0yXmrholeDFJp5cNeI28agTbsZ5oI";
  }

  @override
  Future<String?> getRefreshToken() async {
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjbWdyam1tN20wMDAwcHBweHZoZXhuMm1tIiwiYXBwbGVJZCI6IjAwMTc3NC5mYjZiNjFiMjk5MmU0NjgzOGJlZTM0ZTc4MWE2YTExNC4xMDIxIiwidHlwZSI6ImFjY2VzcyIsImlhdCI6MTc2NzkzMTgyNSwiZXhwIjoxNzY4MDE4MjI1fQ.qtFT_HYrH47xqf0yXmrholeDFJp5cNeI28agTbsZ5oI";
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}

  @override
  Future<void> clear() async {}
}
