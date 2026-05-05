# LTBugly

`LTBugly` 是 `Common` 模块下的自研 Crash 上报组件，当前已经完成 iOS 端增强版 MVP：不仅能做 Crash 捕获、本地落盘、下次启动补偿上传，还补齐了 signal 路径下沉、多线程栈采集、`binary_images`、诊断上下文，以及基础上传策略。

本文档只描述当前仓库里已经落地的实现，并在最后单独列出仍然存在的技术边界与后续规划。

## 当前能力

当前已经落地的入口与核心文件：

- 对外入口：[CrashReporter.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/CrashReporter.swift>)
- Crash 捕获安装：[LTBCrashCapture.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashCapture.swift>)
- Signal C 层处理器：[LTBCrashSignalHandler.m](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashSignalHandler.m>)
- Signal Swift Bridge：[LTBCrashSignalBridge.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashSignalBridge.swift>)
- Crash Report 模型：[LTBCrashReport.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashReport.swift>)
- Report Builder：[LTBCrashReportBuilder.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashReportBuilder.swift>)
- 线程栈采集：[LTBCrashThreadCollector.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashThreadCollector.swift>)
- Binary Images 采集：[LTBCrashBinaryImageCollector.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashBinaryImageCollector.swift>)
- 运行时上下文：[LTBCrashContext.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashContext.swift>)
- 业务上下文存储：[LTBCrashContextStore.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashContextStore.swift>)
- 本地文件存储：[LTBCrashReportStore.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashReportStore.swift>)
- 上传协议与默认上传器：[LTBCrashUploader.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashUploader.swift>)
- 配置项：[LTBCrashReporterConfiguration.swift](</Users/renjun.li/Desktop/LittleThings/LittleThingsApp/core/Common/Source/LTBugly/LTBCrashReporterConfiguration.swift>)

## 已实现功能

### 1. 初始化

组件统一入口仍然是：

```swift
CrashReporter.start()
```

也支持传入完整配置：

```swift
CrashReporter.start(
    configuration: .init(
        endpointURL: URL(string: "https://your-api.com/api/crashes"),
        headers: ["Authorization": "Bearer <token>"],
        maximumReportCount: 10,
        contextConfiguration: .init(breadcrumbCapacity: 50),
        uploadConfiguration: .init(
            maximumRetryCount: 2,
            retryBaseDelay: 2,
            enablesCompression: true
        )
    )
)
```

`start()` 当前会完成这些事情：

- 准备 `CrashReports` 目录
- 清理超过上限的历史 report
- 配置 crash context store
- 同步 `LTLog` breadcrumbs 到 crash context
- 生成 signal 用的上下文模板
- 安装 `NSException` handler
- 安装 C 层 POSIX signal handler
- 扫描本地未上传文件并尝试上传

### 2. 异常捕获

当前已接入两类崩溃捕获：

- `NSException`
- POSIX Signal：
  - `SIGABRT`
  - `SIGSEGV`
  - `SIGBUS`
  - `SIGILL`
  - `SIGFPE`

两条路径现在的策略不同：

- `NSException` 路径：
  - 走 Swift Builder，生成完整 `LTBCrashReport`
  - 采集 App / Device / Context / Threads / Binary Images
  - 写入本地 JSON 文件

- `signal` 路径：
  - handler 已下沉到 `C / Objective-C`
  - 当场只做最小必要工作：从预先同步好的上下文模板出发，补写 signal 异常信息、当前线程 backtrace、binary images
  - 直接使用底层文件 API 落盘
  - 恢复默认 handler 并重新 `raise`

这一版的核心变化是：signal 崩溃现场不再进入 Swift 组装完整 report，减少了异常现场的高层逻辑。

### 3. 存储与补偿上传

当前本地存储策略：

- Crash 文件目录默认位于 `Library/Caches/LTBugly/CrashReports`
- 每个 crash report 存为一个独立 `.json` 文件
- signal 使用额外的 `signal-context.json` 缓存上下文模板
- 下次启动时扫描所有待上传 crash 文件
- 上传成功后立即删除
- 上传失败则保留，等待后续重试
- 最多保留最近 `N` 条，默认 `10` 条

当前 `LTBCrashReportStore` 会自动忽略 `signal-context.json`，它不会被当成 crash event 上传。

### 4. 多线程 backtrace

这一轮已经补上线程采集能力：

- `NSException` 路径：
  - 通过 Mach API 遍历当前进程线程
  - 标记 crashed thread
  - 当前线程通过 `backtrace`
  - 其他线程通过寄存器和 frame pointer 尝试回溯

- `signal` 路径：
  - 当前只稳定记录崩溃线程 backtrace
  - 这是为了控制 signal handler 现场复杂度

也就是说，“多线程 backtrace 能力”已经具备，但完整多线程采集目前主要覆盖 `NSException` 路径。

### 5. Binary Images

`binary_images` 已经补齐基础采集，当前包含：

- `name`
- `uuid`
- `base_address`
- `size`
- `path`

Swift 路径下会通过 `MachO` / `_dyld_*` API 读取 image 列表，并解析 `LC_UUID`。

signal 路径下也会写出 image 列表，但当前为了降低 handler 复杂度：

- `uuid` 暂时写 `null`
- `size` 暂时写 `null`
- `base_address` 和 `path` 已有

这已经足够为后续 dSYM 符号化打下基础，但 signal 路径的 binary image 细节还可以继续增强。

### 6. Breadcrumb / 用户 / Session 上下文

这一轮已经增加 crash context 能力，支持：

- `user_id`
- `session_id`
- `device_id`
- 自定义 `custom` 字段
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

其中 breadcrumb 有两条来源：

- 手动通过 `CrashReporter.addBreadcrumb(...)` 注入
- 从现有 `LTLog.breadcrumbs` 同步

当前 `CrashReporter.start()` 启动时会先同步一次 `LTLog` breadcrumb；如果业务在运行时持续记录 `LTLog` breadcrumb，希望 crash context 始终跟上，建议在关键节点主动调用一次：

```swift
CrashReporter.syncBreadcrumbsFromLogger()
```

### 7. 上传重试、压缩、限流和网络策略

默认上传器 `LTURLSessionCrashUploader` 这轮已经增强：

- 支持 gzip 风格压缩思路的基础压缩实现
  - 当前使用 `NSData.compressed(using: .zlib)`，HTTP Header 为 `Content-Encoding: deflate`
- 支持失败重试
  - 默认指数退避
  - 可配置最大重试次数和起始 delay
- 支持上传限流
  - 复用 `LTLogRateLimitPolicy`
- 支持网络策略
  - `allowsCellularAccess`
  - `allowsExpensiveNetworkAccess`
  - `allowsConstrainedNetworkAccess`
  - `waitsForConnectivity`

配置入口在 `LTBCrashUploadConfiguration`。

## 当前 Report 结构

当前 report 已升级为更完整的结构：

```json
{
  "crash_id": "uuid",
  "timestamp": 1777900000,
  "source": "signal",
  "app": {
    "bundle_id": "com.company.app",
    "version": "1.0.0",
    "build": "100"
  },
  "device": {
    "model": "iPhone15,3",
    "os": "iOS Version 18.4 (Build ...)"
  },
  "exception": {
    "type": "SIGSEGV",
    "name": "SIGSEGV",
    "reason": "invalid memory access"
  },
  "context": {
    "user_id": "user-123",
    "session_id": "session-456",
    "device_id": "device-789",
    "custom": {
      "region": "cn"
    },
    "breadcrumbs": []
  },
  "threads": [
    {
      "number": 12345,
      "name": "main",
      "crashed": true,
      "frames": [
        {
          "instruction_address": "0x0000000101234567",
          "symbol": "closure #1 in ...",
          "image_name": "LittleThingsApp"
        }
      ]
    }
  ],
  "binary_images": [
    {
      "name": "LittleThingsApp",
      "uuid": "AABBCCDD-....",
      "base_address": "0x0000000100000000",
      "size": 123456,
      "path": "/var/containers/Bundle/Application/..."
    }
  ]
}
```

字段说明：

- `source`：区分 `ns_exception` 和 `signal`
- `context`：承载用户态诊断信息
- `threads`：现在是结构化 frame，而不是单纯字符串栈
- `binary_images`：现在已经包含后续符号化需要的基础字段

## 当前技术实现

### 端上流程

```text
App 启动
  -> CrashReporter.start()
  -> 准备目录 / 清理旧文件
  -> 同步 breadcrumb + context 模板
  -> 安装 NSException / signal handler
  -> 扫描本地未上传 report
  -> 尝试上传
  -> 成功删除，失败保留

NSException 发生
  -> Swift Builder 组装完整 report
  -> 采集多线程栈 + binary images + context
  -> JSON 落盘

Signal Crash 发生
  -> C 层 signal handler 读取预先同步的 context 模板
  -> 补写 signal 异常 / 当前线程 backtrace / binary images
  -> 底层文件 API 落盘
  -> 恢复默认 signal 并重新抛出
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
  - 避免在异常现场进入大量 Swift 逻辑

- `LTBCrashReportBuilder`
  - 负责构造完整 report
  - 同时负责 signal 上下文模板

- `LTBCrashThreadCollector`
  - 负责多线程回溯采集

- `LTBCrashBinaryImageCollector`
  - 负责采集 Mach-O binary images

- `LTBCrashContextStore`
  - 保存用户态上下文
  - 保存 breadcrumbs / user_id / session_id / custom

- `LTBCrashReportStore`
  - 负责目录、落盘、扫描、清理

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
        contextConfiguration: .init(breadcrumbCapacity: 50),
        uploadConfiguration: .init(
            maximumRetryCount: 2,
            retryBaseDelay: 2,
            enablesCompression: true
        )
    )
)
```

如果你们已经在使用 `LTLog`，建议同时在用户切换、会话切换、关键页面进入或关键请求前后同步上下文，例如：

```swift
CrashReporter.setUserID(userID)
CrashReporter.setSessionID(sessionID)
CrashReporter.setDeviceID(deviceID)
CrashReporter.syncBreadcrumbsFromLogger()
```

## 当前边界

这一版已经比最初 MVP 稳很多，但还没有到“完整生产级 crash SDK”的终点，当前仍有这些边界：

- signal 路径虽然已经下沉到 C 层，但还没有做到完全严格的 async-signal-safe 审计级实现。
- signal 路径当前只稳定记录崩溃线程，不做完整多线程采集。
- signal 路径的 `binary_images` 还没有补 `uuid` 和 `size`。
- 当前 breadcrumb 与 `LTLog` 是“同步快照”关系，不是自动实时双向联动。
- 上传压缩当前使用 `deflate`，如果服务端严格要求 `gzip`，还需要对齐协议。
- 还没有做脱敏、持久化 breadcrumb ring buffer、OOM / watchdog / ANR 等扩展事件。

## 后续规划

下一阶段建议优先继续做这几件事：

1. 继续收紧 signal handler 的实现，审查所有调用点的 signal-safety。
2. 把 signal 路径的 `binary_images.uuid` 和 `size` 也补齐。
3. 增加持久化 breadcrumb ring buffer，避免崩溃前最后阶段的上下文只存在内存里。
4. 增加字段脱敏策略。
5. 为服务端符号化补齐 dSYM 上传与 UUID 匹配链路。

## 一句话总结

当前 `LTBugly` 已经从最初的闭环 MVP 进化成了增强版采集链路：`NSException 完整采集 + signal C 层最小落盘 + 多线程栈能力 + binary_images + context + 上传重试/压缩/限流/网络策略`。
