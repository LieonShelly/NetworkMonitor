import 'package:dio/dio.dart';
import 'package:ltapp_flutter/src/core/network/api_client.dart';
import 'package:ltapp_flutter/src/core/network/app_exception.dart';
import 'package:ltapp_flutter/src/core/network/auth_interceptor.dart';
import 'package:ltapp_flutter/src/core/network/refresh_token_interceptor.dart';
import 'package:ltapp_flutter/src/core/network/token_storage.dart';

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
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          RefreshTokenInterceptor(_dio, _tokenStorage).onError(error, handler);
        },
      ),
    ]);
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
