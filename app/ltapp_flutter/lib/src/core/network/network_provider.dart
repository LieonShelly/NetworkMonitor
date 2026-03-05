import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/network/api_client.dart';
import 'package:ltapp_flutter/src/core/network/http_api_client.dart';
import 'package:ltapp_flutter/src/core/network/network_config.dart';
import 'package:ltapp_flutter/src/core/network/token_storage.dart';
import 'package:ltapp_flutter/src/core/storage/mock_token_storage.dart';
// import 'package:ltapp_flutter/src/core/storage/secure_token_storage.dart';

const String kBaseUrl = 'https://things.dvacode.tech';
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => MockTokenStorage(),
);

final apiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(baseUrl: kBaseUrl, tokenStorage: storage);
});

final chatApiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(
    baseUrl: NetworkConfig.getChatApiBaseUrl(),
    tokenStorage: storage,
  );
});
