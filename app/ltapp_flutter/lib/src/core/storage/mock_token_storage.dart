import 'package:ltapp_flutter/src/core/network/token_storage.dart';

class MockTokenStorage implements TokenStorage {
  @override
  Future<String?> getAccessToken() async {
    return r"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjbWdyam1tN20wMDAwcHBweHZoZXhuMm1tIiwiYXBwbGVJZCI6IjAwMTc3NC5mYjZiNjFiMjk5MmU0NjgzOGJlZTM0ZTc4MWE2YTExNC4xMDIxIiwidHlwZSI6ImFjY2VzcyIsImlhdCI6MTc2OTI0ODk0MSwiZXhwIjoxNzY5MzM1MzQxfQ.sLp2ujjcYZt04m05vZ7RaqvHTgPTP7EnR6QDbuKoPCc";
  }

  @override
  Future<String?> getRefreshToken() async {
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjbWdyam1tN20wMDAwcHBweHZoZXhuMm1tIiwiYXBwbGVJZCI6IjAwMTc3NC5mYjZiNjFiMjk5MmU0NjgzOGJlZTM0ZTc4MWE2YTExNC4xMDIxIiwidHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjgyMDE5NTksImV4cCI6MTc2OTQ5Nzk1OX0.EsU9be5lIHnnmzj2CYMS3g8ZgCU3t9vXyQx9Ssnoy1E";
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}

  @override
  Future<void> clear() async {}
}
