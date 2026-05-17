# 版权声明批量更新脚本设计

**日期：** 2026-05-17

**作者：** lieon

## 1. 目标

创建一个 Shell 脚本，用于批量更新项目中所有代码文件的版权声明为统一格式。

## 2. 目标样式

```
//
//  Created by lieon on {year}/{month}/{day}.
//  This code is protected by intellectual property rights.
//
```

## 3. 目标文件范围

- `.swift` 文件
- `.h` Objective-C 头文件
- `.m` Objective-C 实现文件

**总计约 311 个文件**

## 4. 需要替换的现有样式

脚本需要检测并替换以下版权声明样式：

| 样式编号 | 模式 | 示例 |
|---------|------|------|
| 1 | Xcode 默认模板 | `//  Created by Renjun Li on 2025/12/17.` |
| 2 | Codex 生成 | `//  Created by Codex on 2026/5/5.` |
| 3 | LittleThings AI | `//  Created by LittleThings AI on 2026/05/17.` |
| 4 | 简洁保护声明 | `//  This code is protected by intellectual property rights.` |
| 5 | AI 生成（lieon AI） | `//  Created by lieon AI on 2026/05/17.` |

## 5. 技术方案

### 5.1 使用的工具

- `find` - 递归查找目标文件
- `sed` - 文本替换
- `perl` - 多行正则表达式处理
- `date` - 获取当前日期

### 5.2 排除目录

以下目录将被排除：
- `Pods/`
- `.build/`
- `DerivedData/`
- `Carthage/`
- `vendor/`
- `node_modules/`

## 6. 脚本结构

```bash
#!/bin/bash

# ==================== 配置区域 ====================
AUTHOR="lieon"
FILE_EXTENSIONS="swift h m"
EXCLUDE_DIRS="Pods .build DerivedData Carthage vendor node_modules .git"

# ==================== 版权声明模板 ====================
generate_copyright_header() {
    local current_date=$(date "+%Y/%m/%d")
    cat <<EOF
//
//  Created by ${AUTHOR} on ${current_date}.
//  This code is protected by intellectual property rights.
//
EOF
}

# ==================== 核心函数 ====================
- scan_files()         # 扫描项目文件
- process_file()       # 处理单个文件
- replace_copyright()   # 替换版权声明
- add_copyright()      # 添加版权声明
- backup_file()        # 备份原文件

# ==================== 主程序 ====================
main() {
    # 1. 扫描文件
    # 2. 遍历处理每个文件
    # 3. 生成报告
}
```

## 7. 执行流程

```
┌─────────────────┐
│  1. 初始化配置   │
└────────┬────────┘
         ↓
┌─────────────────┐
│  2. 获取当前日期  │
└────────┬────────┘
         ↓
┌─────────────────┐
│  3. 扫描代码文件  │
└────────┬────────┘
         ↓
    ┌────┴────┐
    │ 遍历文件 │
    └────┬────┘
         ↓
┌─────────────────┐
│ 4a. 有版权声明？  │
│     ├─ 是 → 替换 │
│     └─ 否 → 添加 │
└────────┬────────┘
         ↓
┌─────────────────┐
│  5. 生成处理报告  │
└─────────────────┘
```

## 8. 错误处理

- 跳过二进制文件
- 跳过符号链接（避免循环）
- 报告处理失败的文件
- 提供干运行模式（预览模式，不实际修改）

## 9. 使用方式

```bash
# 常规运行
./update_copyright.sh

# 预览模式（不实际修改）
./update_copyright.sh --dry-run

# 指定作者
./update_copyright.sh --author "Custom Name"
```

## 10. 输出示例

```
开始处理版权声明...
==============================
总计文件: 311
已处理: 305
跳过: 6 (无变化)
失败: 0
==============================
完成！
```
