# 快速修复指南：localhost连接问题

## ✅ 已修复的问题

### 1. 代理配置问题
**问题**：代理（Charles/Fiddler）拦截了localhost请求  
**修复**：localhost请求现在会绕过代理，直接连接

### 2. 平台兼容性
**问题**：不同平台访问localhost的方式不同  
**修复**：自动根据平台选择正确的地址
- iOS模拟器：`http://localhost:8000`
- Android模拟器：`http://10.0.2.2:8000`
- 其他：`http://127.0.0.1:8000`

### 3. 调试日志
**新增**：详细的网络请求日志，方便排查问题

---

## 🚀 现在测试

### 步骤1：确保Python后端运行
```bash
# 确保后端绑定到0.0.0.0
python your_server.py
# 或
uvicorn main:app --host 0.0.0.0 --port 8000
```

### 步骤2：重新运行Flutter应用
```bash
# 停止当前应用
# 然后重新运行
flutter run
```

### 步骤3：查看日志
发送消息后，查看控制台输出：
```
🌐 Request: POST http://localhost:8000/chat
📤 Data: {session_id: ios_expert_001, message: 你的消息}
🔧 Proxy config for localhost: DIRECT
📥 Response: 200
```

---

## 🔍 如果还是不行

### 检查清单

#### 1. 确认Python后端正在运行
```bash
# 测试后端是否可访问
curl http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "test", "message": "hello"}'
```

#### 2. 检查后端绑定地址
```python
# ❌ 错误 - 只能本机访问
app.run(host='127.0.0.1', port=8000)

# ✅ 正确 - 可以被其他设备访问
app.run(host='0.0.0.0', port=8000)
```

#### 3. 检查防火墙
```bash
# macOS - 查看防火墙状态
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# 临时关闭防火墙测试（不推荐长期使用）
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
```

#### 4. 使用实际IP地址（真机测试）
如果在真机上测试，需要修改 `lib/src/core/network/network_config.dart`：

```dart
static String getRealDeviceApiUrl() {
  // 替换为你的电脑IP地址
  return 'http://192.168.1.100:8000';  // 改成你的实际IP
}
```

然后在network_provider.dart中使用：
```dart
final chatApiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(
    baseUrl: NetworkConfig.getRealDeviceApiUrl(),  // 使用真机地址
    tokenStorage: storage,
  );
});
```

查找你的IP地址：
```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig | findstr IPv4
```

---

## 📊 调试技巧

### 1. 查看详细的网络日志
现在每个请求都会打印详细日志：
- 🌐 请求URL和方法
- 📤 发送的数据
- 🔧 代理配置
- 📥 响应状态
- ❌ 错误信息

### 2. 测试代理配置
在 `lib/src/core/network/network_config.dart` 中：
```dart
// 临时禁用代理测试
static const bool enableProxy = false;  // 改为false
```

### 3. 使用Charles/Fiddler抓包
如果需要抓包调试：
1. 确保代理工具运行在 `127.0.0.1:8888`
2. 在 `network_config.dart` 中设置 `enableProxy = true`
3. localhost请求会自动绕过代理

---

## 🎯 常见错误和解决方案

### 错误1: "Connection refused"
**原因**：后端未运行或端口不对  
**解决**：
```bash
# 检查端口是否被占用
lsof -i :8000

# 确保后端运行在8000端口
python your_server.py
```

### 错误2: "Connection timeout"
**原因**：防火墙阻止或网络不通  
**解决**：
- 检查防火墙设置
- 确保手机和电脑在同一WiFi
- 使用ping测试连通性

### 错误3: "Host not found"
**原因**：DNS解析失败  
**解决**：
- 使用IP地址而不是域名
- 检查网络连接

---

## 📝 配置文件说明

### network_config.dart
- 管理所有网络配置
- 自动选择合适的API地址
- 控制代理设置

### network_provider.dart
- 提供API客户端实例
- 使用NetworkConfig获取配置

### http_api_client.dart
- 实现HTTP请求
- 处理代理配置
- 添加调试日志

---

## ✨ 最佳实践

### 开发环境
```dart
// 使用自动配置
baseUrl: NetworkConfig.getChatApiBaseUrl()
```

### 生产环境
```dart
// 使用环境变量
baseUrl: const String.fromEnvironment('API_BASE_URL')
```

### 多环境配置
```dart
enum Environment { dev, staging, prod }

class NetworkConfig {
  static Environment currentEnv = Environment.dev;
  
  static String getApiBaseUrl() {
    switch (currentEnv) {
      case Environment.dev:
        return getChatApiBaseUrl();
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.prod:
        return 'https://api.example.com';
    }
  }
}
```

---

## 🎓 学到了什么？

通过解决这个问题，你学到了：

1. **网络配置** - 不同平台访问localhost的方式
2. **代理设置** - 如何配置代理和绕过规则
3. **调试技巧** - 如何添加日志排查网络问题
4. **最佳实践** - 如何组织网络配置代码

这些都是资深Flutter工程师必备的技能！
