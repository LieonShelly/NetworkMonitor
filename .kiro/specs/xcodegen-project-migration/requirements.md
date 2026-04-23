# Requirements Document

## Introduction

将现有 `app/LTApp/LTApp.xcodeproj` 手动维护的 Xcode 项目文件迁移为通过 XcodeGen 工具自动生成。迁移完成后，生成的 `.xcodeproj` 配置须与现有项目完全一致，后续所有项目配置变更均通过编辑 `project.yml` 完成。项目中 `core/` 下的 Network、Persistence、Common、UIComponent 模块已使用 XcodeGen 管理，本次迁移需与已有模块的配置风格保持一致。

## Glossary

- **XcodeGen**: 基于 YAML 配置文件（`project.yml`）自动生成 Xcode 项目文件（`.xcodeproj`）的命令行工具
- **project.yml**: XcodeGen 的项目配置文件，定义 targets、build settings、dependencies、schemes 等
- **settings.yml**: 位于 `fastlane/project/settings.yml` 的共享构建配置文件，定义了所有模块通用的 setting groups 和 scheme templates
- **LTApp**: 主应用 target，类型为 iOS application，Bundle ID 为 `com.little.things`
- **LTAppTests**: 单元测试 target，类型为 unit-test bundle，依赖 LTApp
- **Core_Modules**: 位于 `core/` 目录下的四个框架模块：LTNetwork、LTCommon、Persistence、UIComponent
- **SPM_Dependencies**: 通过 Swift Package Manager 引入的第三方库：Kingfisher、SVGKit（含 SVGKit 和 SVGKitSwift 两个 product）
- **Fastlane**: CI/CD 自动化工具，用于构建和分发应用到 TestFlight
- **Build_Configuration**: Xcode 构建配置，当前项目包含 Debug、Release、Release-Debug 三种配置

## Requirements

### Requirement 1: 创建 LTApp 的 project.yml 配置文件

**User Story:** 作为开发者，我希望为 LTApp 创建一个 XcodeGen 的 `project.yml` 配置文件，以便通过 XcodeGen 自动生成 `.xcodeproj` 文件。

#### Acceptance Criteria

1. THE project.yml SHALL be located at `app/LTApp/project.yml`
2. THE project.yml SHALL include the shared settings file via `include: ../../fastlane/project/settings.yml`
3. THE project.yml SHALL define the project name as `LTApp`
4. THE project.yml SHALL define the project-level settings group as `BaseProjectSetting`

### Requirement 2: 配置 LTApp 主 Target

**User Story:** 作为开发者，我希望 project.yml 中的 LTApp target 配置与现有 xcodeproj 完全一致，以便迁移后应用行为不变。

#### Acceptance Criteria

1. THE project.yml SHALL define the LTApp target with type `application` and platform `iOS`
2. THE project.yml SHALL configure the LTApp target sources to include `LTApp/Source` directory
3. THE project.yml SHALL configure the LTApp target resources to include `LTApp/Resource/Assets.xcassets`, `LTApp/Resource/LaunchScreen.storyboard`, and `LTApp/Resource/Info.plist`
4. THE project.yml SHALL include `LTApp/Source/Domain/Thread/test_rocket.png` as a resource in the LTApp target
5. THE project.yml SHALL set `PRODUCT_BUNDLE_IDENTIFIER` to `com.little.things` for the LTApp target
6. THE project.yml SHALL set `PRODUCT_NAME` to `LTApp` for the LTApp target
7. THE project.yml SHALL set `SWIFT_VERSION` to `6.0` for the LTApp target
8. THE project.yml SHALL set `IPHONE_DEPLOYMENT_TARGET` to `18.0` for the LTApp target
9. THE project.yml SHALL set `INFOPLIST_FILE` to `LTApp/Resource/Info.plist` for the LTApp target
10. THE project.yml SHALL set `CODE_SIGN_ENTITLEMENTS` to `LTApp/Resource/LTApp.entitlements` for the LTApp target

### Requirement 3: 配置代码签名设置

**User Story:** 作为开发者，我希望 project.yml 中的代码签名配置与现有项目一致，以便 Debug 和 Release 构建都能正确签名。

#### Acceptance Criteria

1. THE project.yml SHALL set `CODE_SIGN_STYLE` to `Manual` for the LTApp target
2. THE project.yml SHALL set `DEVELOPMENT_TEAM` to `R7S4TKW9JF` for the LTApp target
3. WHILE in Debug configuration, THE project.yml SHALL set `CODE_SIGN_IDENTITY` to `Apple Development` for the LTApp target
4. WHILE in Debug configuration, THE project.yml SHALL set `PROVISIONING_PROFILE_SPECIFIER` to `little.things.dev.profile` for the LTApp target
5. WHILE in Release configuration, THE project.yml SHALL set `CODE_SIGN_IDENTITY` to `iPhone Distribution: Shanghai Weishu Weixiang Network Technology Co., Ltd. (R7S4TKW9JF)` for the LTApp target
6. WHILE in Release configuration, THE project.yml SHALL set `PROVISIONING_PROFILE_SPECIFIER` to `little.things.adhoc.profile` for the LTApp target
7. WHILE in Release-Debug configuration, THE project.yml SHALL replicate the Release configuration signing settings for the LTApp target

### Requirement 4: 配置构建配置（Build Configurations）

**User Story:** 作为开发者，我希望 project.yml 定义与现有项目一致的三种构建配置，以便所有构建场景都能正常工作。

#### Acceptance Criteria

1. THE project.yml SHALL define three build configurations: Debug, Release, and Release-Debug
2. THE project.yml SHALL map Debug configuration to `debug` type
3. THE project.yml SHALL map Release configuration to `release` type
4. THE project.yml SHALL map Release-Debug configuration to `release` type with debug-level Swift optimization (`-Onone`)
5. WHILE in Release-Debug configuration, THE project.yml SHALL set `OTHER_SWIFT_FLAGS` to `-DDEBUG` for the project-level settings
6. THE project.yml SHALL set `defaultConfig` to `Debug`

### Requirement 5: 配置 SPM 依赖

**User Story:** 作为开发者，我希望 project.yml 正确声明所有 Swift Package Manager 依赖，以便第三方库能正确集成。

#### Acceptance Criteria

1. THE project.yml SHALL declare Kingfisher package with repository URL `https://github.com/onevcat/Kingfisher` and minimum version `8.6.2` using `upToNextMajor` version strategy
2. THE project.yml SHALL declare SVGKit package with repository URL `https://github.com/SVGKit/SVGKit` and minimum version `3.0.0` using `upToNextMajor` version strategy
3. THE project.yml SHALL add Kingfisher as a dependency of the LTApp target
4. THE project.yml SHALL add SVGKit and SVGKitSwift as dependencies of the LTApp target

### Requirement 6: 配置 Core 模块框架依赖

**User Story:** 作为开发者，我希望 project.yml 正确引用 core 模块的 framework 产物，以便 LTApp 能链接并嵌入这些框架。

#### Acceptance Criteria

1. THE project.yml SHALL add LTNetwork.framework as a dependency of the LTApp target with embed and code-sign-on-copy attributes
2. THE project.yml SHALL add Persistence.framework as a dependency of the LTApp target with embed and code-sign-on-copy attributes
3. THE project.yml SHALL add UIComponent.framework as a dependency of the LTApp target with embed and code-sign-on-copy attributes
4. THE project.yml SHALL add LTCommon.framework as a dependency of the LTApp target with embed and code-sign-on-copy attributes

### Requirement 7: 配置 LTAppTests Target

**User Story:** 作为开发者，我希望 project.yml 正确配置单元测试 target，以便能运行现有的单元测试。

#### Acceptance Criteria

1. THE project.yml SHALL define the LTAppTests target with type `bundle.unit-test` and platform `iOS`
2. THE project.yml SHALL configure the LTAppTests target sources to include `LTApp/Tests` directory
3. THE project.yml SHALL set the LTAppTests target to depend on the LTApp target
4. THE project.yml SHALL set `GENERATE_INFOPLIST_FILE` to `true` for the LTAppTests target
5. THE project.yml SHALL set `PRODUCT_BUNDLE_IDENTIFIER` to `com.LTAppTests` for the LTAppTests target

### Requirement 8: 配置 Scheme

**User Story:** 作为开发者，我希望 project.yml 定义与现有项目一致的 scheme，以便 Xcode 和 Fastlane 能正确识别构建方案。

#### Acceptance Criteria

1. THE project.yml SHALL define an `LTApp` scheme that builds the LTApp target
2. THE project.yml SHALL configure the LTApp scheme to run LTAppTests as the test target
3. THE project.yml SHALL configure the LTApp scheme with code coverage gathering enabled

### Requirement 9: 配置平台支持设置

**User Story:** 作为开发者，我希望 project.yml 中的平台支持设置与现有项目一致，以便应用在正确的设备上运行。

#### Acceptance Criteria

1. THE project.yml SHALL set `SUPPORTED_PLATFORMS` to `iphoneos iphonesimulator` for the LTApp target
2. THE project.yml SHALL set `TARGETED_DEVICE_FAMILY` to `1,2` for the LTApp target
3. THE project.yml SHALL set `SUPPORTS_MACCATALYST` to `NO` for the LTApp target
4. THE project.yml SHALL set `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD` to `YES` for the LTApp target
5. THE project.yml SHALL set `SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD` to `YES` for the LTApp target

### Requirement 10: 更新 Fastlane 生成命令

**User Story:** 作为开发者，我希望 Fastlane 的 `generate_project` lane 能正确生成 LTApp 的项目文件，以便 CI/CD 流程能自动化生成项目。

#### Acceptance Criteria

1. THE Fastlane `generate_project` lane SHALL execute XcodeGen with the LTApp project.yml configuration file path
2. THE Fastlane `generate_project` lane SHALL generate the LTApp.xcodeproj in the `app/LTApp/` directory

### Requirement 11: 更新 .gitignore 配置

**User Story:** 作为开发者，我希望 `.gitignore` 排除 XcodeGen 生成的 `.xcodeproj` 文件，以便版本控制中只保留 `project.yml` 源文件。

#### Acceptance Criteria

1. THE .gitignore SHALL include a rule to ignore `*.xcodeproj` files for XcodeGen-managed projects
2. THE .gitignore SHALL retain the `xcuserdata/` ignore rule

### Requirement 12: 保持与现有 Core 模块配置风格一致

**User Story:** 作为开发者，我希望 LTApp 的 project.yml 与已有 core 模块的配置风格保持一致，以便整个项目的 XcodeGen 配置具有统一性。

#### Acceptance Criteria

1. THE project.yml SHALL use the same `include` mechanism as core module project.yml files to reference `settings.yml`
2. THE project.yml SHALL use `settingGroups` references (e.g., `BaseTargetSetting`) consistent with core module configurations
3. THE project.yml SHALL follow the same YAML formatting conventions as the existing core module project.yml files
