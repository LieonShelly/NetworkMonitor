# 共享依赖版本管理

本文档定义了项目中所有包应该使用的标准依赖版本。

## 核心依赖

### 状态管理
```yaml
flutter_riverpod: ^3.1.0
riverpod_annotation: ^4.0.0
```

### 路由
```yaml
go_router: ^17.0.0
```

### 国际化
```yaml
intl: ^0.20.2
```

### 数据序列化
```yaml
freezed_annotation: ^3.1.0
json_annotation: ^4.8.1
```

### 网络
```yaml
dio: ^5.9.0
```

### UI 组件
```yaml
flutter_svg: ^2.0.9
cached_network_image: ^3.4.1
```

### 存储
```yaml
flutter_secure_storage: ^10.0.0
```

## 开发依赖

### 代码生成
```yaml
build_runner: ^2.4.8
riverpod_generator: ^4.0.0+1
freezed: ^3.2.3
json_serializable: ^6.7.1
```

### 代码质量
```yaml
flutter_lints: ^6.0.0
flutter_test:
  sdk: flutter
```

## 使用指南

### Domain 包标准依赖

大多数 domain 包应该包含：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.1.0
  riverpod_annotation: ^4.0.0
  
  # 根据需要添加
  go_router: ^17.0.0  # 如果需要路由
  intl: ^0.20.2       # 如果需要日期格式化
  freezed_annotation: ^3.1.0  # 如果使用 Freezed

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.8
  riverpod_generator: ^4.0.0+1
  freezed: ^3.2.3  # 如果使用 Freezed
```

### Service 包标准依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.1.0
  riverpod_annotation: ^4.0.0
  freezed_annotation: ^3.1.0
  json_annotation: ^4.8.1
  dio: ^5.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.8
  riverpod_generator: ^4.0.0+1
  freezed: ^3.2.3
  json_serializable: ^6.7.1
```

### Core 包标准依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  # 根据具体包的功能添加最小依赖

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

## 版本更新流程

1. 在本文档中更新版本号
2. 运行同步脚本（如果有）或手动更新各个 pubspec.yaml
3. 在根目录运行 `flutter pub get` 或 `melos bootstrap`
4. 测试所有包确保兼容性
5. 提交更改

## 依赖更新检查

定期检查依赖更新：
```bash
# 检查过期依赖
flutter pub outdated

# 使用 Melos 检查所有包
melos exec -- flutter pub outdated
```
