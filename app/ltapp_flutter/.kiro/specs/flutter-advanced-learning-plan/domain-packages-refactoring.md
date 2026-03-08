# Domain Packages 重构记录

## 重构内容

将 `packages/domain` 目录下所有包的 `domain_` 前缀去除，使包名更简洁。

## 重命名列表

| 原包名 | 新包名 | 描述 |
|--------|--------|------|
| domain_thread | thread | Thread 功能模块 |
| domain_calendar | calendar | 日历功能模块 |
| domain_today_question | today_question | 今日问题模块 |
| domain_user | user | 用户模块 |
| domain_add_answer | add_answer | 添加答案模块 |
| domain_answer_detail | answer_detail | 答案详情模块 |
| domain_wallet | wallet | 钱包模块 |
| domain_copilot | copilot | AI助手/聊天模块 |
| domain_common | common | 通用组件模块 |

## 修改内容

### 1. 目录重命名
```bash
packages/domain/domain_thread     -> packages/domain/thread
packages/domain/domain_calendar   -> packages/domain/calendar
packages/domain/domain_today_question -> packages/domain/today_question
# ... 其他模块
```

### 2. pubspec.yaml 更新
每个包的 `pubspec.yaml` 中的 `name` 字段已更新：
```yaml
# 修改前
name: domain_thread

# 修改后
name: thread
```

### 3. 库文件重命名
主库文件名已更新：
```
packages/domain/thread/lib/domain_thread.dart -> packages/domain/thread/lib/thread.dart
packages/domain/calendar/lib/domain_calendar.dart -> packages/domain/calendar/lib/calendar.dart
# ... 其他模块
```

### 4. library 声明更新
每个库文件中的 `library` 声明已更新：
```dart
// 修改前
library domain_thread;

// 修改后
library thread;
```

## 包结构

重构后的包结构：
```
packages/domain/
├── add_answer/
│   ├── lib/
│   │   ├── add_answer.dart
│   │   └── src/
│   └── pubspec.yaml
├── answer_detail/
│   ├── lib/
│   │   ├── answer_detail.dart
│   │   └── src/
│   └── pubspec.yaml
├── calendar/
│   ├── lib/
│   │   ├── calendar.dart
│   │   └── src/
│   └── pubspec.yaml
├── common/
│   ├── lib/
│   │   ├── common.dart
│   │   └── src/
│   └── pubspec.yaml
├── copilot/
│   ├── lib/
│   │   ├── copilot.dart
│   │   └── src/
│   └── pubspec.yaml
├── thread/
│   ├── lib/
│   │   ├── thread.dart
│   │   └── src/
│   └── pubspec.yaml
├── today_question/
│   ├── lib/
│   │   ├── today_question.dart
│   │   └── src/
│   └── pubspec.yaml
├── user/
│   ├── lib/
│   │   ├── user.dart
│   │   └── src/
│   └── pubspec.yaml
└── wallet/
    ├── lib/
    │   ├── wallet.dart
    │   └── src/
    └── pubspec.yaml
```

## 后续步骤

### 1. 更新主项目依赖
需要在主项目的 `pubspec.yaml` 中更新这些包的引用：

```yaml
dependencies:
  # 修改前
  domain_thread:
    path: packages/domain/domain_thread
  
  # 修改后
  thread:
    path: packages/domain/thread
```

### 2. 更新导入语句
在使用这些包的代码中更新 import 语句：

```dart
// 修改前
import 'package:domain_thread/domain_thread.dart';

// 修改后
import 'package:thread/thread.dart';
```

### 3. 运行依赖更新
```bash
flutter pub get
```

### 4. 重新生成代码
如果包中有使用代码生成（如 Riverpod、Freezed），需要重新运行：
```bash
cd packages/domain/thread
flutter pub run build_runner build --delete-conflicting-outputs
```

## 优势

1. **更简洁的包名**: 去掉冗余的 `domain_` 前缀
2. **更清晰的导入**: `import 'package:thread/thread.dart'` 比 `import 'package:domain_thread/domain_thread.dart'` 更简洁
3. **符合 Flutter 命名规范**: 包名应该简短且具有描述性
4. **更好的可读性**: 在依赖声明和导入语句中更易读

## 注意事项

- 所有引用这些包的代码都需要更新导入语句
- 如果有其他项目依赖这些包，也需要同步更新
- 建议在更新后运行完整的测试套件确保没有遗漏
