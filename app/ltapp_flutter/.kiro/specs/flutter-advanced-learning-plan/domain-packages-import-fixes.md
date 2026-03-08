# Domain Packages Import 修复记录

## 修复概述

修复了 `packages/domain` 目录下所有 Flutter 包中的 import 错误，将相对路径和错误的包引用替换为正确的 package 导入。

## 修复的包

1. **thread** - Thread 功能模块
2. **calendar** - 日历功能模块
3. **today_question** - 今日问题模块
4. **user** - 用户模块
5. **add_answer** - 添加答案模块
6. **answer_detail** - 答案详情模块
7. **wallet** - 钱包模块
8. **copilot** - AI助手/聊天模块
9. **common** - 通用组件模块

## 修复的 Import 类型

### 1. 相对路径 → Package 导入

**修复前**:
```dart
import '../../../../../../packages/core/theme/app_style.dart';
import '../../../../../../packages/core/theme/icon_name.dart';
import '../../../../../../packages/core/ui_component/svg_asset.dart';
```

**修复后**:
```dart
import 'package:lt_uicomponent/uicomponent.dart';
```

### 2. 错误的包名 → 正确的包名

**修复前**:
```dart
import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';
import 'package:ltapp_flutter/src/service/providers/providers.dart';
import 'package:ltapp_flutter/src/domain/calendar/calendar_controller.dart';
```

**修复后**:
```dart
import 'package:lt_reflection_service/reflection_service.dart';
import 'calendar_controller.dart';
```

### 3. 模块内部引用 → 相对导入

**修复前**:
```dart
import 'package:ltapp_flutter/src/domain/calendar/calendar_content_view.dart';
```

**修复后**:
```dart
import 'calendar_content_view.dart';
```

## 详细修复列表

### Calendar 包
- ✅ `date_utl` 相对路径 → `package:date_utl/date_utl.dart`
- ✅ `app_style`, `icon_name`, `svg_asset` → `package:lt_uicomponent/uicomponent.dart`
- ✅ 内部文件引用改为相对导入
- ✅ Service 引用 → `package:lt_reflection_service/reflection_service.dart`

### Thread 包
- ✅ `theme.dart` → `package:lt_uicomponent/uicomponent.dart`
- ✅ `thread_page_controller.dart` 改为相对导入
- ✅ Service 引用 → `package:lt_reflection_service/reflection_service.dart`
- ✅ 修复 part 文件路径

### Today Question 包
- ✅ UI 组件 → `package:lt_uicomponent/uicomponent.dart`
- ✅ Service 引用 → `package:lt_reflection_service/reflection_service.dart`

### Common 包
- ✅ `app_tabbar.dart`, `svg_asset.dart` 改为相对导入
- ✅ `today_question_banner_view` → `package:today_question/today_question.dart`
- ✅ UI 组件 → `package:lt_uicomponent/uicomponent.dart`

### User 包
- ✅ UI 组件 → `package:lt_uicomponent/uicomponent.dart`

### Answer Detail 包
- ✅ UI 组件 → `package:lt_uicomponent/uicomponent.dart`
- ✅ Service 引用 → `package:lt_reflection_service/reflection_service.dart`

### Wallet 包
- ✅ `chain_service` → `package:chain_service/chain_service.dart`

### Copilot 包
- ✅ `network_provider` → `package:network/network.dart`

### Add Answer 包
- ✅ 已经使用正确的 package 导入，无需修复

## 依赖关系图

```
domain packages
├── thread → lt_uicomponent, lt_reflection_service
├── calendar → lt_uicomponent, lt_reflection_service, date_utl
├── today_question → lt_uicomponent, lt_reflection_service
├── user → lt_uicomponent
├── add_answer → lt_uicomponent, lt_reflection_service
├── answer_detail → lt_uicomponent, lt_reflection_service
├── wallet → chain_service
├── copilot → network
└── common → lt_uicomponent, today_question
```

## 后续步骤

### 1. 运行 pub get
每个包都需要运行依赖更新：
```bash
cd packages/domain/thread && flutter pub get
cd packages/domain/calendar && flutter pub get
# ... 对所有包执行
```

### 2. 重新生成代码
对于使用代码生成的包（如 thread, calendar, today_question, add_answer）：
```bash
cd packages/domain/thread
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 验证编译
```bash
flutter analyze packages/domain
```

## 注意事项

1. **重复导入**: 某些文件可能有重复的 `import 'package:lt_uicomponent/uicomponent.dart'`，需要手动清理
2. **Part 文件路径**: 确保 `part` 指令使用相对路径而不是绝对路径
3. **循环依赖**: 注意 common 包依赖 today_question，确保不会形成循环依赖

## 修复命令总结

使用的主要 sed 命令：
```bash
# 修复相对路径
find packages/domain -name "*.dart" -exec sed -i '' "s|'../../../../../../packages/core/theme/app_style.dart'|'package:lt_uicomponent/uicomponent.dart'|g" {} \;

# 修复错误的包名
find packages/domain -name "*.dart" -exec sed -i '' "s|'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart'|'package:lt_reflection_service/reflection_service.dart'|g" {} \;

# 修复内部引用
find packages/domain -name "*.dart" -exec sed -i '' "s|'package:ltapp_flutter/src/domain/calendar/|'|g" {} \;
```

## 验证清单

- [ ] 所有包的 pubspec.yaml 依赖正确
- [ ] 没有相对路径导入（除了同包内文件）
- [ ] 没有 `ltapp_flutter` 包引用
- [ ] 代码生成文件路径正确
- [ ] 运行 `flutter analyze` 无错误
- [ ] 所有包可以独立编译
