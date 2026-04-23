# Implementation Plan: XcodeGen 项目迁移

## Overview

将 `app/LTApp/LTApp.xcodeproj` 从手动维护迁移为 XcodeGen 自动生成。按照增量步骤依次完成：创建 `project.yml` 配置文件 → 更新 Fastlane → 更新 `.gitignore` → 验证生成结果。每个步骤都基于前一步骤的产物，最终通过 XcodeGen 生成与现有项目完全一致的 `.xcodeproj`。

## Tasks

- [x] 1. 创建 app/LTApp/project.yml 核心配置文件
  - [x] 1.1 创建 project.yml 并配置项目级设置
    - 在 `app/LTApp/project.yml` 创建文件
    - 添加 `include: ../../fastlane/project/settings.yml` 引用共享配置
    - 设置项目名称为 `LTApp`
    - 配置 `settings.groups` 引用 `BaseProjectSetting`
    - 定义三种构建配置：Debug → debug、Release → release、Release-Debug → release
    - 设置 `defaultConfig: Debug`
    - 在项目级 settings.configs.Release-Debug 中设置 `SWIFT_OPTIMIZATION_LEVEL: "-Onone"` 和 `OTHER_SWIFT_FLAGS: "-DDEBUG"`
    - 参考 `core/Network/project.yml` 的格式风格保持一致
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 12.1, 12.3_

  - [x] 1.2 配置 LTApp 主 Target
    - 在 `targets` 节点下定义 `LTApp` target，type 为 `application`，platform 为 `iOS`
    - 配置 `sources` 指向 `LTApp/Source`
    - 配置 `resources` 列表包含：`LTApp/Resource/Assets.xcassets`、`LTApp/Resource/LaunchScreen.storyboard`、`LTApp/Resource/Info.plist`、`LTApp/Source/Domain/Thread/test_rocket.png`
    - 配置 `settings.groups` 引用 `BaseTargetSetting`
    - 配置 `settings.base` 中的通用 build settings：PRODUCT_BUNDLE_IDENTIFIER、PRODUCT_NAME、SWIFT_VERSION、IPHONE_DEPLOYMENT_TARGET、INFOPLIST_FILE、CODE_SIGN_ENTITLEMENTS、SUPPORTED_PLATFORMS、TARGETED_DEVICE_FAMILY、SUPPORTS_MACCATALYST、SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD、SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD
    - 具体值参见设计文档 1.2 节
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 9.1, 9.2, 9.3, 9.4, 9.5, 12.2_

  - [x] 1.3 配置代码签名设置
    - 在 LTApp target 的 `settings.base` 中设置 `CODE_SIGN_STYLE: Manual` 和 `DEVELOPMENT_TEAM: R7S4TKW9JF`
    - 在 `settings.configs.Debug` 中设置 Debug 签名：CODE_SIGN_IDENTITY 和 PROVISIONING_PROFILE_SPECIFIER
    - 在 `settings.configs.Release` 中设置 Release 签名
    - 在 `settings.configs.Release-Debug` 中复制 Release 签名配置
    - 具体值参见设计文档 1.2 节
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [x] 1.4 配置 SPM 依赖
    - 在 `packages` 节点声明 Kingfisher（url: https://github.com/onevcat/Kingfisher, from: "8.6.2"）
    - 在 `packages` 节点声明 SVGKit（url: https://github.com/SVGKit/SVGKit, from: "3.0.0"）
    - 在 LTApp target 的 `dependencies` 中添加 `package: Kingfisher`
    - 在 LTApp target 的 `dependencies` 中添加 `package: SVGKit, product: SVGKit` 和 `package: SVGKit, product: SVGKitSwift`
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [x] 1.5 配置 Core 模块框架依赖
    - 在 LTApp target 的 `dependencies` 中添加四个 framework 依赖：LTNetwork、Persistence、UIComponent、LTCommon
    - 每个 framework 设置 `embed: true` 和 `codeSign: true`
    - 使用相对路径引用 `../../core/{module}/build/Build/Products/Debug-iphonesimulator/{framework}.framework`
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 1.6 配置 LTAppTests Target
    - 在 `targets` 节点下定义 `LTAppTests` target，type 为 `bundle.unit-test`，platform 为 `iOS`
    - 配置 `sources` 指向 `LTApp/Tests`
    - 添加对 LTApp target 的依赖
    - 设置 `GENERATE_INFOPLIST_FILE: true` 和 `PRODUCT_BUNDLE_IDENTIFIER: com.LTAppTests`
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

  - [x] 1.7 配置 Scheme
    - 在 `schemes` 节点定义 `LTApp` scheme
    - 配置 build targets 包含 LTApp: all
    - 配置 test targets 包含 LTAppTests（randomExecutionOrder: false）
    - 启用 `gatherCoverageData: true`
    - _Requirements: 8.1, 8.2, 8.3_

- [x] 2. Checkpoint - 验证 project.yml 配置
  - 检查 `app/LTApp/project.yml` 文件是否存在且 YAML 语法正确
  - 确认所有 requirements 1-9, 12 的配置项都已包含
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. 更新 Fastlane 和 .gitignore
  - [x] 3.1 更新 Fastlane generate_project lane
    - 在 `fastlane/Fastfile` 的 `generate_project` lane 中新增一行命令
    - 添加 `sh("xcodegen generate -s ../app/LTApp/project.yml --project ../app/LTApp")`
    - 保留原有的 `sh("xcodegen generate -s project/project.yml")` 命令
    - _Requirements: 10.1, 10.2_

  - [x] 3.2 更新 .gitignore
    - 在 `.gitignore` 文件中取消注释或添加 `*.xcodeproj` 规则
    - 确保保留已有的 `xcuserdata/` 忽略规则
    - _Requirements: 11.1, 11.2_

- [x] 4. 验证 XcodeGen 项目生成
  - [x] 4.1 运行 XcodeGen 生成项目
    - 在 `app/LTApp/` 目录下执行 `xcodegen generate`
    - 验证 `LTApp.xcodeproj` 目录被成功创建
    - 验证 `project.pbxproj` 文件存在
    - 如果生成失败，根据错误信息修正 project.yml 配置
    - _Requirements: 1.1, 2.1_

  - [ ]* 4.2 验证 build settings 正确性
    - 使用 `xcodebuild -project app/LTApp/LTApp.xcodeproj -target LTApp -configuration Debug -showBuildSettings` 检查关键 build settings
    - 验证 PRODUCT_BUNDLE_IDENTIFIER、SWIFT_VERSION、CODE_SIGN_STYLE、DEVELOPMENT_TEAM 等值正确
    - _Requirements: 2.5, 2.7, 3.1, 3.2, 4.1_

- [x] 5. Final checkpoint - 确认迁移完成
  - 确认 project.yml 已创建且配置完整
  - 确认 Fastlane generate_project lane 已更新
  - 确认 .gitignore 已更新
  - 确认 XcodeGen 能成功生成项目
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- 标记 `*` 的任务为可选任务，可跳过以加快 MVP 进度
- 每个任务引用了具体的 requirements 编号以确保可追溯性
- Core 框架的路径可能需要根据实际构建产物位置调整，实施时需验证
- 本次迁移属于 IaC 类型变更，不涉及 property-based testing
- 参考文件：`core/Network/project.yml`（配置风格参考）、`fastlane/project/settings.yml`（共享构建配置）
