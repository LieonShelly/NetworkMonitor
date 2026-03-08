import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network_core/api_client.dart';
import 'http_api_client.dart';
import 'network_config.dart';
import '../network_core/token_storage.dart';
import './mock_token_storage.dart';
import './secure_token_storage.dart';

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
