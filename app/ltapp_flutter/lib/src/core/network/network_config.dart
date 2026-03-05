import 'dart:io';

class NetworkConfig {
  static const bool enableProxy = false; // kDebugMode;
  static const String proxyHost = '127.0.0.1';
  static const String proxyPort = '8888';

  static String getProxyConfig(Uri uri) {
    if (_isLocalAddress(uri.host)) {
      return 'DIRECT';
    }
    if (enableProxy) {
      return 'PROXY $proxyHost:$proxyPort';
    }
    return 'DIRECT';
  }

  static bool _isLocalAddress(String host) {
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host.startsWith('192.168.') ||
        host.startsWith('10.0.') ||
        host.startsWith('172.16.') ||
        host.endsWith('.local');
  }

  static String getChatApiBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else if (Platform.isIOS) {
      return 'http://localhost:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  static String getRealDeviceApiUrl() {
    return 'http://192.168.1.100:8000';
  }
}
