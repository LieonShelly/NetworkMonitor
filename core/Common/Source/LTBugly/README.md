# LTBugly

`LTBugly` 是 `Common` 模块下的自研稳定性组件，当前已完成客户端增强版实现：支持 `NSException` / POSIX Signal 崩溃采集、本地落盘、下次启动补偿上传、signal 路径最小化处理、多线程栈能力、`binary_images`、上下文持久化、字段脱敏、稳定性事件采集，以及 dSYM 上传契约。

这份文档只描述当前仓库里已经落地的客户端能力。服务端 symbol worker、UUID 索引和重新符号化能力不在本轮实现范围内，后续单独推进。

## 当前能力

核心文件：

- 对外入口：[CrashReporter.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/CrashReporter.swift>)
- Crash 捕获安装：[LTBCrashCapture.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashCapture.swift>)
- Signal C 层处理器：[LTBCrashSignalHandler.m](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashSignalHandler.m>)
- Signal Bridge：[LTBCrashSignalBridge.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashSignalBridge.swift>)
- Crash Report 模型：[LTBCrashReport.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashReport.swift>)
- 稳定性事件模型：[LTBCrashEvent.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashEvent.swift>)
- Symbolication 元数据：[LTBCrashSymbolicationMetadata.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashSymbolicationMetadata.swift>)
- Report Builder：[LTBCrashReportBuilder.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashReportBuilder.swift>)
- 线程栈采集：[LTBCrashThreadCollector.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashThreadCollector.swift>)
- Binary Images 采集：[LTBCrashBinaryImageCollector.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashBinaryImageCollector.swift>)
- 运行时上下文：[LTBCrashContext.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashContext.swift>)
- 业务上下文存储：[LTBCrashContextStore.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashContextStore.swift>)
- 字段脱敏：[LTBCrashRedactor.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashRedactor.swift>)
- 稳定性监控：[LTBCrashStabilityMonitor.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashStabilityMonitor.swift>)
- App 状态追踪：[LTBCrashAppStateTracker.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashAppStateTracker.swift>)
- 本地文件存储：[LTBCrashReportStore.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashReportStore.swift>)
- 上传器：[LTBCrashUploader.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashUploader.swift>)
- 配置项：[LTBCrashReporterConfiguration.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashReporterConfiguration.swift>)
- dSYM 上传脚本：[scripts/ltbugly_upload_dsym.sh](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/scripts/ltbugly_upload_dsym.sh>)
- Fastlane lane：[fastlane/Fastfile](/Users/renjun.li/Desktop/LittleThings/LittleThingsApp/fastlane/Fastfile)

## 已实现功能

### 1. 初始化

入口：

```swift
CrashReporter.start()
```

完整配置示例：

```swift
CrashReporter.start(
    configuration: .init(
        endpointURL: URL(string: "https://your-api.com/api/crashes"),
        headers: ["Authorization": "Bearer <token>"],
        maximumReportCount: 10,
        contextConfiguration: .init(
            breadcrumbCapacity: 50,
            persistenceConfiguration: .init(
                debounceInterval: 1,
                breadcrumbFileCount: 3,
                maximumBreadcrumbsPerFile: 50
            )
        ),
        uploadConfiguration: .init(
            maximumRetryCount: 2,
            retryBaseDelay: 2,
            enablesCompression: true
        ),
        redactionPolicy: .default
    )
)
```

`start()` 当前会完成：

- 准备 `CrashReports` 目录
- 清理超过上限的历史 report
- 配置并恢复 crash context
- 同步 `LTLog` breadcrumbs
- 生成 signal 用的上下文模板
- 安装 `NSException` handler
- 安装 C 层 signal handler
- 启动 app state tracker
- 启动稳定性事件监控
- 扫描本地未上传文件并尝试上传

### 2. 崩溃捕获

当前已接入：

- `NSException`
- POSIX Signal
  - `SIGABRT`
  - `SIGSEGV`
  - `SIGBUS`
  - `SIGILL`
  - `SIGFPE`

两条路径的策略不同：

- `NSException` 路径
  - 走 Swift Builder 生成完整 `LTBCrashReport`
  - 采集 App / Device / Context / Threads / Binary Images / Symbolication Metadata
  - 写入本地 JSON 文件

- `signal` 路径
  - handler 下沉到 `C / Objective-C`
  - 现场只补 signal 异常信息、线程号和当前线程原始地址 backtrace
  - `binary_images`、上下文、symbolication metadata 提前准备进 signal 模板
  - 直接使用底层文件 API 落盘
  - 使用 `sigaction(..., SA_RESETHAND, ...)`，随后 `raise(signal)`

这一轮 signal handler 继续收紧了调用面，现场已经进一步去掉了：

- `dladdr` 符号解析
- 线程名读取
- 通用 JSON 转义型字符串拼接

也就是说，signal 现场现在更偏向：

- 读取预先准备好的模板
- 写固定字段
- 写时间戳 / 线程号
- 写原始地址 backtrace

### 3. 存储与补偿上传

本地存储策略：

- Crash 文件目录默认位于 `Library/Caches/LTBugly/CrashReports`
- 每个 crash report 存为一个独立 `.json` 文件
- 稳定性事件存为 `event-*.json`
- signal 使用额外的 `signal-context.json` 缓存上下文模板
- context 持久化使用 `context.json`
- breadcrumb 轮转持久化使用 `breadcrumbs-0.json`、`breadcrumbs-1.json` 等
- 下次启动时扫描所有待上传文件
- 上传成功后立即删除
- 上传失败则保留，等待后续重试
- 最多保留最近 `N` 条，默认 `10` 条

### 4. 多线程 backtrace

当前线程采集能力：

- `NSException` 路径
  - 通过 Mach API 遍历当前进程线程
  - 标记 crashed thread
  - 当前线程通过 `backtrace`
  - 其他线程通过寄存器和 frame pointer 尝试回溯

- `signal` 路径
  - 当前只稳定记录崩溃线程原始地址 backtrace
  - 继续优先保证 signal handler 的现场复杂度可控

### 5. Binary Images 与符号化元数据

`binary_images` 当前包含：

- `name`
- `uuid`
- `base_address`
- `size`
- `path`

Swift 路径通过 `MachO` / `_dyld_*` API 读取 image 列表，并解析 `LC_UUID` 与 image size。

signal 路径不再在 crash 现场动态遍历 `binary_images`，而是提前把完整 image 信息放入 signal 模板，因此当前 signal report 也能带出：

- `uuid`
- `size`
- `base_address`
- `path`

report 里还额外增加了 `symbolication` 字段：

- `bundle_id`
- `version`
- `build`
- `binary_image_uuids`

这部分用于后续服务端 dSYM UUID 匹配。

### 6. Breadcrumb / 用户 / Session 上下文

当前已支持：

- `user_id`
- `session_id`
- `device_id`
- 自定义 `custom`
- `breadcrumbs`

对外 API：

```swift
CrashReporter.setUserID("user-123")
CrashReporter.setSessionID("session-456")
CrashReporter.setDeviceID("device-789")
CrashReporter.setCustomValue("cn", forKey: "region")
CrashReporter.addBreadcrumb("enter payment page", category: "navigation")
CrashReporter.syncBreadcrumbsFromLogger()
```

breadcrumb 来源：

- 手动通过 `CrashReporter.addBreadcrumb(...)` 注入
- 从现有 `LTLog.breadcrumbs` 同步

这些上下文不仅存在内存中，还会持久化到本地文件，作为 signal 模板的基础数据来源。

### 7. Context 持久化策略优化

当前 context 持久化已经做了两层优化：

- debounce 刷盘
  - 不再每次字段变更都立即写盘
  - 合并短时间内的多次修改

- breadcrumb 文件轮转
  - 将 breadcrumbs 拆分成多个文件块持久化
  - 限制单文件条数和总文件数

相关配置在 `LTBCrashPersistenceConfiguration`：

- `debounceInterval`
- `breadcrumbFileCount`
- `maximumBreadcrumbsPerFile`

### 8. 字段脱敏

当前已经加入基础脱敏策略，作用范围包括：

- `user_id`
- `session_id`
- `device_id`
- `custom`
- breadcrumb 的 `message`
- breadcrumb 的 `metadata`

默认策略会处理：

- 常见敏感 key，如 `token`、`password`、`authorization`、`cookie`、`email`、`phone`
- email 文本模式
- 电话号码文本模式

同时已经支持字段级白名单 / 黑名单模式：

- `keyMode: .blacklist`
- `keyMode: .whitelist`

入口在 `LTBCrashRedactionPolicy`，可以通过 `CrashReporter.start(configuration:)` 自定义。

### 9. 稳定性事件扩展

除了 crash report，这轮补了一组客户端稳定性事件骨架：

- `memory_pressure`
  - 监听 `UIApplication.didReceiveMemoryWarningNotification`
- `app_hang_risk`
  - watchdog 定时 ping 主线程，记录明显主线程卡顿风险
- `watchdog_risk`
  - 通过前后台驻留时间粗略记录 watchdog 风险
- `abnormal_termination`
  - 基于 app state 持久化，在下次启动时识别上次非正常退出痕迹

这些事件会以 `LTBCrashEvent` 的形式落到本地，和 crash report 走同一套补偿上传链路。

说明：

- 这是客户端侧的基础监控骨架，不等价于“已经完整实现系统级 OOM / 真正 watchdog / ANR 检测”
- `abnormal_termination` 目前仍然是客户端侧线索，还不是系统级 OOM / Jetsam 的精确归因

### 10. 上传重试、压缩、限流和网络策略

默认上传器 `LTURLSessionCrashUploader` 已支持：

- 基础压缩
  - 当前使用 `NSData.compressed(using: .zlib)`
  - `Content-Encoding: deflate`
- 失败重试
  - 默认指数退避
  - 可配置最大重试次数和起始 delay
- 上传限流
  - 复用 `LTLogRateLimitPolicy`
- 网络策略
  - `allowsCellularAccess`
  - `allowsExpensiveNetworkAccess`
  - `allowsConstrainedNetworkAccess`
  - `waitsForConnectivity`

### 11. dSYM 上传与 UUID 匹配契约

客户端这边已经补齐两部分：

- crash report 中的 `binary_images.uuid`
- `symbolication.binary_image_uuids`

工程侧补了一个基础 dSYM 上传脚本：

- [scripts/ltbugly_upload_dsym.sh](/Users/renjun.li/Desktop/LittleThings/LittleThingsApp/scripts/ltbugly_upload_dsym.sh)

以及一个 Fastlane lane：

```ruby
fastlane ios upload_ltb_dsym \
  dsym_path:"/path/to/App.app.dSYM" \
  upload_url:"https://your-api.com/api/symbols/dsym" \
  bundle_id:"com.little.things" \
  version:"1.0.0" \
  build:"100"
```

脚本会：

- 用 `dwarfdump --uuid` 读取 dSYM UUID
- 打包 `.dSYM`
- 以 multipart form 上传
- 附带 `uuids`、`bundle_id`、`version`、`build`

注意：真正的服务端 symbol worker、UUID 索引和重新符号化能力这轮没有实现，当前只是把客户端和构建侧契约补齐。

## 当前技术实现

### 端上流程

```text
App 启动
  -> CrashReporter.start()
  -> 准备目录 / 清理旧文件
  -> 恢复 context 持久化数据
  -> 同步 breadcrumb + signal 模板
  -> 启动 app state tracker
  -> 安装 NSException / signal handler
  -> 启动稳定性监控
  -> 扫描本地未上传 report / event
  -> 检查上次是否异常退出
  -> 尝试上传
  -> 成功删除，失败保留

NSException 发生
  -> Swift Builder 组装完整 report
  -> 采集多线程栈 + binary images + context + symbolication metadata
  -> JSON 落盘

Signal Crash 发生
  -> C 层 signal handler 读取预先同步的 signal 模板
  -> 补写 signal 异常 / 当前线程号 / 当前线程原始地址 backtrace
  -> 底层文件 API 落盘
  -> 恢复默认 signal 行为并重新抛出

稳定性风险发生
  -> 生成 LTBCrashEvent
  -> 本地落盘
  -> 下次启动或当前会话补偿上传
```

### 模块职责

- `CrashReporter`
  - 对外门面
  - 管理配置、上下文同步、启动后补偿上传

- `LTBCrashCapture`
  - 安装 `NSException` 捕获
  - 将 signal 捕获接到 C 层

- `LTBCrashSignalHandler`
  - 在 signal 现场做最小落盘
  - 现场不再动态采集 `binary_images`
  - 不再做 `dladdr` 符号解析和线程名读取
  - 避免在异常现场进入大量 Swift 逻辑

- `LTBCrashReportBuilder`
  - 构造完整 report
  - 负责 signal 上下文模板
  - 负责 symbolication metadata

- `LTBCrashThreadCollector`
  - 负责多线程回溯采集

- `LTBCrashBinaryImageCollector`
  - 负责采集 Mach-O binary images

- `LTBCrashContextStore`
  - 保存用户态上下文
  - 保存 breadcrumbs / user_id / session_id / custom
  - 将上下文持久化到本地
  - 使用 debounce + 文件轮转优化刷盘

- `LTBCrashRedactor`
  - 负责敏感字段和文本模式脱敏
  - 支持字段级白名单 / 黑名单策略

- `LTBCrashStabilityMonitor`
  - 负责 memory pressure / hang risk / watchdog risk 的客户端监控

- `LTBCrashAppStateTracker`
  - 负责持久化 app state
  - 在下次启动时生成 abnormal termination 线索事件

- `LTBCrashReportStore`
  - 负责 crash report / stability event 的目录、落盘、扫描、清理

- `LTBCrashUploader`
  - 负责上传策略
  - 包含压缩、重试、限流和网络约束

## 推荐接入方式

建议在 App 启动早期调用：

```swift
CrashReporter.start(
    configuration: .init(
        endpointURL: URL(string: "https://your-api.com/api/crashes"),
        maximumReportCount: 10,
        contextConfiguration: .init(
            breadcrumbCapacity: 50,
            persistenceConfiguration: .init(
                debounceInterval: 1,
                breadcrumbFileCount: 3,
                maximumBreadcrumbsPerFile: 50
            )
        ),
        uploadConfiguration: .init(
            maximumRetryCount: 2,
            retryBaseDelay: 2,
            enablesCompression: true
        ),
        redactionPolicy: .default
    )
)
```

如果你们已经在使用 `LTLog`，建议在用户切换、会话切换、关键页面进入或关键请求前后同步上下文，例如：

```swift
CrashReporter.setUserID(userID)
CrashReporter.setSessionID(sessionID)
CrashReporter.setDeviceID(deviceID)
CrashReporter.syncBreadcrumbsFromLogger()
```

## 当前边界

这一版已经比最初 MVP 稳很多，但还没有到“完整生产级 crash SDK”的终点，当前仍有这些边界：

- signal 路径虽然已经继续收紧，并显著减少了现场动态调用，但依然没有做到“所有调用点都经过严格 async-signal-safe 白名单证明”的审计级实现
- signal 路径当前只稳定记录崩溃线程原始地址 backtrace，不做完整多线程采集
- signal 路径为了安全性牺牲了现场符号信息，符号名和 image name 主要依赖后续离线符号化
- 当前的上下文持久化已经做了 debounce 和轮转，但依然属于轻量级 snapshot/ring buffer
- 当前 breadcrumb 与 `LTLog` 还是“同步快照”关系，不是自动实时联动
- 上传压缩当前使用 `deflate`，如果服务端严格要求 `gzip`，还需要对齐协议
- 服务端 symbol worker、UUID 索引和重新符号化能力这轮未实现，后续单独推进
- 当前稳定性事件更多是“风险信号 + 异常终止线索”，还不是完整的系统级 OOM / watchdog / ANR / Jetsam 诊断

## 后续规划

下一阶段建议优先继续做这几件事：

1. 继续把 signal handler 收敛到更严格的 async-signal-safe 子集
2. 进一步优化 context 持久化的刷盘策略和轮转策略
3. 单独推进服务端 symbol worker、UUID 索引和重新符号化能力
4. 增加更细粒度的字段级白名单 / 黑名单脱敏规则
5. 扩展 OOM / watchdog / ANR / 卡死等稳定性事件的系统级诊断能力

## 一句话总结

当前 `LTBugly` 已经从最初的闭环 MVP 进化成了增强版客户端稳定性链路：`NSException 完整采集 + signal C 层最小落盘 + 多线程栈能力 + binary_images/UUID + context 持久化 + 字段脱敏 + 稳定性事件骨架 + 上传重试/压缩/限流/网络策略 + dSYM 上传契约`。
