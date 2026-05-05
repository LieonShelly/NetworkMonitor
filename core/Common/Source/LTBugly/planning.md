# LTBugly 研发路线图

LTBugly 是一个为 LittleThingsApp 打造的自研崩溃采集与分析平台。本计划旨在从 MVP 版本开始，逐步迭代出一个成熟的稳定性工程平台。

---

## MVP 版本：端到端闭环
**目标**：实现 App 崩溃采集、下次启动上传，以及服务端原始 Crash 信息的展示。

### iOS 端能力
- **初始化**：`CrashReporter.start()`
- **异常捕获**：
  - `NSException`
  - **POSIX Signal**：`SIGABRT`、`SIGSEGV`、`SIGBUS`、`SIGILL`、`SIGFPE`
- **存储与策略**：
  - Crash 发生时仅写入本地文件，**严禁**进行网络请求。
  - 下次启动扫描本地文件并尝试上传。
  - 上传成功后立即删除，失败则保留并重试。
  - **阈值管理**：最多保留最近 N 条（如 10 条）。

### MVP 上报字段 (JSON)
```json
{
  "crash_id": "uuid",
  "timestamp": 1777900000,
  "app": {
    "bundle_id": "com.company.app",
    "version": "1.0.0",
    "build": "100"
  },
  "device": {
    "model": "iPhone15,3",
    "os": "iOS 18.4"
  },
  "exception": {
    "type": "SIGSEGV",
    "name": "SIGSEGV",
    "reason": "invalid memory access"
  },
  "threads": [],
  "binary_images": []
}
```

### 服务端能力
- **API**：`POST /api/crashes`
- **存储**：保存原始 JSON 报文。
- **查询**：支持按 `app_version`、`device_model`、`exception_type` 过滤。
- **基础展示**：列表展示时间、版本、异常类型及崩溃线程地址。

> [!WARNING]
> **MVP 注意点**：
> 1. Crash Handler 中严禁调用 Swift 高级对象逻辑。
> 2. Signal Handler 内不可进行 JSON 序列化、网络上传或数据库写入。
> 3. 初期可专注实现 `NSSetUncaughtExceptionHandler` + `signal` + `backtrace`。

---

## 1.0 版本：提高采集质量
**目标**：使 Crash Report 包含更多可供分析的元数据。

### iOS 端增强
- **线程回溯**：采集所有线程的 Backtrace 并标记崩溃线程。
- **采集 Binary Images**：
  - Image Name & UUID
  - Load Address
  - Image Path (用于符号化)
- **用户上下文**：
  - 记录 `breadcrumbs`（页面进入、点击、API 请求、状态变化）。
  - 记录 `user_id`、`session_id`、`device_id`。
- **隐私与性能**：
  - **隐私过滤**：手机号、邮箱、Token 等敏感信息脱敏。
  - **上报优化**：使用 Gzip 压缩，实施指数退避重试策略。

### 服务端增强
- **多维统计**：App 版本表、设备维度分布。
- **可视化**：展示 Breadcrumbs、支持 Raw Crash 下载。
- **状态流转**：`new` -> `processing` -> `symbolicated` / `failed`。

---

## 2.0 版本：服务端符号化
**目标**：将“十六进制地址堆栈”进化为“可读代码堆栈”。

### dSYM 管理
- 集成 CI 在构建后自动上传 dSYM。
- 服务端解析 dSYM UUID，并与 Report 中的 Binary Image UUID 进行匹配。

### 符号化流程
```text
  frame_address
- image_load_address
+ image_vm_address
= symbol_address (用于匹配 dSYM)
```

### 符号化工具集
```bash
# 获取 dSYM UUID
dwarfdump --uuid App.dSYM

# 手动验证地址
atos -o App.dSYM/Contents/Resources/DWARF/App -arch arm64 -l <load_address> <frame_address>
```

### 服务端新增能力
- **自动符号化队列**。
- **失败归因**：记录 `dSYM missing`、`UUID mismatch` 等原因。
- **缺失提醒**：当收到无 dSYM 的上报时触发提醒。

---

## 3.0 版本：Crash 聚合与 Fingerprint
**目标**：将同类问题自动归档，消除冗余信息。

### 聚合逻辑 (Fingerprint)
```text
fingerprint = exception_type + crashed_thread_top_app_frames + app_binary_uuid
```

### 服务端能力
- **Issue 模型**：一个 Issue 对应多个 Event。
- **统计指标**：影响用户数、发生频率、首发版本、回归检测。
- **状态管理**：`open`、`resolved`、`ignored`、`regression`。

---

## 4.0 版本：诊断体验增强
**目标**：全方位还原崩溃现场。

### 增强采集
- **自动面包屑**：自动捕获页面跳转。
- **网络快照**：URL Path、Method、Status Code、Duration。
- **系统状态**：内存占用、前后台状态、启动耗时、自定义 Tag。

### 服务端增强
- **问题时间线**：展示崩溃前后的完整事件流。
- **稳定性看板**：Crash-free Users / Sessions 指标。

---

## 5.0 版本：稳定性治理平台
**目标**：闭环驱动稳定性工程化。

- **告警集成**：Slack / 飞书 / 邮件实时告警，支持阈值配置。
- **工程化对接**：自动归因至 Commit、与工单系统同步。
- **全方位监控**：采集 ANR、卡死、OOM、Watchdog、Jetsam 等事件。
- **前沿技术**：Swift Concurrency 崩溃特征识别。

---

## 推荐实现顺序

1.  **基础设施**：先做通用日志上报 SDK（本地队列、批量上传、重试、隐私脱敏）。
2.  **核心捕获**：实现 Crash 本地落盘（Signal/Exception 捕获）及启动后上传。
3.  **解析链路**：服务端符号化与 dSYM 自动化管理。
4.  **平台化**：聚合、看板、告警。

> **核心逻辑**：Crash 发生时进程已不可靠，因此上报逻辑应尽可能复用已稳定的“普通日志模块”。

---

## 技术选型建议

| 模块 | 建议选型 |
| :--- | :--- |
| **iOS 底层** | C / Objective-C 实现 Handler，Swift 提供对外 API |
| **本地存储** | `Library/Caches/CrashReports` |
| **网络层** | `URLSession` + JSON (后续可切 Protobuf) |
| **服务端接收** | 任意高性能 Web 框架 |
| **元数据存储** | PostgreSQL / MySQL |
| **符号化引擎** | atos / llvm-symbolizer (异步队列处理) |

---

## 一句话路线图
**MVP** 抓现场 -> **2.0** 看堆栈 -> **3.0** 聚问题 -> **4.0+** 治稳定性。






## 后续规划

### 下一步优先事项

1. 把 signal crash 落盘下沉到 C / Objective-C 层，减少在异常现场执行的高层逻辑。
2. 增加多线程 backtrace 采集能力。
3. 补齐 `binary_images`，为后续 dSYM 符号化做准备。
4. 增加 breadcrumb、用户信息、session 信息等诊断上下文。
5. 增加上传重试、压缩、限流和网络策略。

### 1.0 版本

目标：提高 crash report 的可分析性。

- 采集所有线程 backtrace
- 记录 crashed thread index
- 填充 binary image UUID、load address、path
- 记录 breadcrumb、user_id、session_id
- 增加敏感信息脱敏
- 上传支持 gzip 和指数退避

### 2.0 版本

目标：打通服务端符号化。

- 构建产物上传 dSYM
- 服务端按 UUID 匹配 dSYM
- 通过地址 + image 信息恢复函数名、文件名、行号

### 3.0 版本

目标：从单条 event 升级到 issue 聚合。

- 基于堆栈生成 fingerprint
- 相同 crash 聚合为 issue
- 增加影响用户数、发生次数、首次出现版本、回归检测

### 4.0 版本及以后

- 诊断时间线
- 稳定性看板
- 阈值告警
- OOM / watchdog / ANR / 卡死扩展采集

## 一句话总结

当前 `LTBugly` 已经完成了 MVP 第一阶段：`Crash 捕获 -> 本地 JSON 落盘 -> 下次启动补偿上传 -> 成功删除 / 失败保留 / 最多保留 N 条`。

后续的重点，是把这条链路从“能用”继续推到“足够稳、足够全、足够可诊断”。
