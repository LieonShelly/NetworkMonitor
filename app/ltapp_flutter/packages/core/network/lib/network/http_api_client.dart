import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../network_core/api_client.dart';
import '../network_core/app_exception.dart';
import 'auth_interceptor.dart';
import 'network_config.dart';
import 'refresh_token_interceptor.dart';
import '../network_core/token_storage.dart';

class HttpApiClient implements ApiClientType {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  HttpApiClient({required String baseUrl, required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Content-Type": 'application/json',
          "Accept": 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([
      AuthInterceptor(storage: _tokenStorage),
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            debugPrint(
              '🌐 Request: ${options.method} ${options.baseUrl}${options.path}',
            );
            debugPrint('📤 Data: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('📥 Response: ${response.statusCode}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('❌ Error: ${error.message}');
            debugPrint('   Type: ${error.type}');
            debugPrint('   URL: ${error.requestOptions.uri}');
          }
          RefreshTokenInterceptor(_dio, _tokenStorage).onError(error, handler);
        },
      ),
    ]);

    if (kDebugMode) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) {
            final proxyConfig = NetworkConfig.getProxyConfig(uri);
            debugPrint('🔧 Proxy config for ${uri.host}: $proxyConfig');
            return proxyConfig;
          };
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException error) {
    return NetworkException(message: error.message ?? "Unkown Error");
  }
}
