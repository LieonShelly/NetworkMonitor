class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? identifier;

  AppException({required this.message, this.statusCode, this.identifier});

  @override
  String toString() {
    return 'AppException: message=$message, statusCode=$statusCode, identifier=$identifier';
  }
}

class NetworkException extends AppException {
  NetworkException({super.message = '网络连接失败，请检查网络'});
}

class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = '网络连接失败，请检查网络'});
}
