# iOS/Android 访问 localhost 问题解决方案

## 🔍 问题描述

在Flutter应用中访问本地后端服务（如 `http://127.0.0.1:8000`）时，出现 "Connection refused" 错误，但使用curl命令可以正常访问。

## 🎯 根本原因

### iOS模拟器
- iOS模拟器中的 `127.0.0.1` 指向模拟器自己，而不是宿主机
- 需要使用 `localhost` 或宿主机的实际IP地址

### Android模拟器
- Android模拟器中的 `127.0.0.1` 也指向模拟器自己
- 需要使用 `10.0.2.2`（Android模拟器的特殊地址，指向宿主机）

## ✅ 解决方案

### 方案1：使用 localhost（推荐用于iOS模拟器）

```dart
// lib/src/core/network/network_provider.dart
final chatApiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(
    baseUrl: 'http://localhost:8000',  // ✅ 使用localhost
    tokenStorage: storage,
  );
});
```

### 方案2：根据平台动态选择地址

```dart
import 'dart:io';

final chatApiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  
  // 根据平台选择合适的地址
  String baseUrl;
  if (Platform.isAndroid) {
    baseUrl = 'http://10.0.2.2:8000';  // Android模拟器
  } else if (Platform.isIOS) {
    baseUrl = 'http://localhost:8000';  // iOS模拟器
  } else {
    baseUrl = 'http://127.0.0.1:8000';  // 其他平台
  }
  
  return HttpApiClient(baseUrl: baseUrl, tokenStorage: storage);
});
```

### 方案3：使用实际IP地址（推荐用于真机测试）

```dart
final chatApiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  
  // 使用电脑的局域网IP地址
  // 在终端运行 ifconfig (Mac/Linux) 或 ipconfig (Windows) 查看IP
  return HttpApiClient(
    baseUrl: 'http://192.168.1.100:8000',  // 替换为你的实际IP
    tokenStorage: storage,
  );
});
```

### 方案4：使用环境变量（最佳实践）

```dart
// lib/src/core/config/env_config.dart
class EnvConfig {
  static const String chatApiBaseUrl = String.fromEnvironment(
    'CHAT_API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}

// lib/src/core/network/network_provider.dart
final chatApiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(
    baseUrl: EnvConfig.chatApiBaseUrl,
    tokenStorage: storage,
  );
});
```

运行时指定：
```bash
# iOS模拟器
flutter run --dart-define=CHAT_API_BASE_URL=http://localhost:8000

# Android模拟器
flutter run --dart-define=CHAT_API_BASE_URL=http://10.0.2.2:8000

# 真机（替换为实际IP）
flutter run --dart-define=CHAT_API_BASE_URL=http://192.168.1.100:8000
```

## 🔧 如何查找电脑的IP地址

### macOS/Linux
```bash
ifconfig | grep "inet "
# 或
ipconfig getifaddr en0
```

### Windows
```bash
ipconfig
# 查找 "IPv4 地址"
```

### 快速方法
```bash
# macOS
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'

# Linux
hostname -I | awk '{print $1}'
```

## 📱 不同场景的配置

| 场景 | iOS | Android | 说明 |
|------|-----|---------|------|
| 模拟器开发 | `localhost:8000` | `10.0.2.2:8000` | 最常用 |
| 真机测试 | `192.168.x.x:8000` | `192.168.x.x:8000` | 需要同一WiFi |
| 生产环境 | `https://api.example.com` | `https://api.example.com` | 使用域名 |

## ⚠️ 注意事项

### 1. 防火墙设置
确保防火墙允许8000端口的连接：

```bash
# macOS - 临时允许
sudo pfctl -d  # 禁用防火墙（不推荐）

# 或者添加规则允许8000端口
```

### 2. 后端服务绑定地址
确保Python后端绑定到 `0.0.0.0` 而不是 `127.0.0.1`：

```python
# ❌ 只能本机访问
app.run(host='127.0.0.1', port=8000)

# ✅ 可以被局域网访问
app.run(host='0.0.0.0', port=8000)
```

### 3. iOS App Transport Security (ATS)
如果使用HTTP（非HTTPS），需要在 `ios/Runner/Info.plist` 中配置：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <!-- 或者允许所有HTTP（仅用于开发） -->
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 4. Android网络权限
确保 `android/app/src/main/AndroidManifest.xml` 中有网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

并且允许HTTP流量（Android 9+）：

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

## 🧪 测试连接

### 1. 测试后端是否可访问

```bash
# 从终端测试
curl http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "test", "message": "hello"}'

# 从手机浏览器测试（使用实际IP）
http://192.168.1.100:8000
```

### 2. Flutter中添加调试日志

```dart
Future<void> _handleSubmitted(String text) async {
  try {
    final apiClient = ref.read(chatApiClientProvider);
    debugPrint('🌐 Sending request to: ${apiClient.baseUrl}/chat');
    debugPrint('📤 Request data: {"session_id": "$sessionId", "message": "$text"}');
    
    final response = await apiClient.post(
      '/chat',
      data: {'session_id': sessionId, 'message': text},
    );
    
    debugPrint('📥 Response: $response');
    // ...
  } catch (e, stackTrace) {
    debugPrint('❌ Error: $e');
    debugPrint('📍 Stack trace: $stackTrace');
    // ...
  }
}
```

## 📚 相关资源

- [Flutter网络请求最佳实践](https://flutter.dev/docs/cookbook/networking/fetch-data)
- [Dio配置文档](https://pub.dev/packages/dio)
- [iOS ATS配置](https://developer.apple.com/documentation/security/preventing_insecure_network_connections)
- [Android网络安全配置](https://developer.android.com/training/articles/security-config)

## 🎓 学习要点

这个问题涉及到Flutter开发中的几个重要概念：

1. **网络配置** - 不同平台的localhost处理方式
2. **环境管理** - 如何在不同环境使用不同配置
3. **调试技巧** - 如何排查网络问题
4. **安全配置** - HTTP vs HTTPS的配置

这些都是资深Flutter工程师必须掌握的技能！
