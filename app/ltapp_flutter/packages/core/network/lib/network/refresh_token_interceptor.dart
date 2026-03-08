import 'package:dio/dio.dart';
import '../network_core/token_storage.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _storage;

  RefreshTokenInterceptor(this._dio, this._storage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _storage.clear();
      return handler.next(err);
    }
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        return handler.next(err);
      }
      final refreshResponse = await Dio().post(
        'https://things.dvacode.tech/api/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final newAccesToken = refreshResponse.data['data']['accessToken'];
      final newRrefreshToken = refreshResponse.data['data']['refreshToken'];
      await _storage.saveTokens(newAccesToken, newRrefreshToken);

      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccesToken';
      final cloneReq = await _dio.fetch(opts);
      return handler.resolve(cloneReq);
    } on DioException catch (e) {
      await _storage.clear();
      return handler.next(e);
    } catch (e) {
      return handler.next(err);
    }
  }
}
