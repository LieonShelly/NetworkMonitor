
# iOS 越狱检测 Framework 功能需求清单

> **架构定位**：采用 **Swift** 为主语言，核心检测手段绕过 `Foundation` 框架，直接调用底层 **Darwin** 模块（C API）实现。

---

## 模块一：多维度底层探测引擎 (Detection Engine)
本模块负责环境收集与状态评估，所有检测方法不返回绝对的 `true/false`，而是累加风险分值。

### 1. 越狱文件与路径嗅探
- **能力描述**：检测系统中是否存在常见的越狱工具和环境依赖路径（如 `/Applications/Cydia.app`、`/Library/MobileSubstrate/MobileSubstrate.dylib`、`/bin/bash` 等）。
- **技术要求**：严禁使用 `FileManager` 等高级 API。必须直接引入 `Darwin` 模块，使用 `stat()` 或 `access()` 等 C 语言函数进行路径校验。

### 2. 沙盒逃逸与越权检测
- **能力描述**：验证应用当前的沙盒机制是否被攻破。
- **技术要求**：尝试使用 C API 向 `/private/` 或 `/` 等系统受限目录写入一段临时数据；检查 `/Applications` 等目录是否被非法篡改为 **Symbolic Link**（软链接）。

### 3. 非法动态库 (Dylib) 监控
- **能力描述**：检测当前 App 进程是否被注入了越狱插件。
- **技术要求**：使用底层函数 `_dyld_image_count()` 和 `_dyld_get_image_name()` 遍历当前加载的动态库，匹配是否包含 `MobileSubstrate`、`CydiaSubstrate`、`frida` 等敏感特征字眼。

### 4. URL Scheme 探针
- **能力描述**：尝试嗅探设备是否安装了特定的越狱商店。
- **技术要求**：调用 `UIApplication.shared.canOpenURL` 检查能否响应 `cydia://` 或 `sileo://` 等协议头。

---

## 模块二：框架自身的反制与防护 (Self-Protection)
本模块负责保护 Framework 内部的安全逻辑不被静态分析工具轻易破解。

### 1. 敏感字符串混淆 (XOR String Obfuscation)
- **能力描述**：抹除 Mach-O 文件中的越狱特征字符串明文。
- **技术要求**：针对模块一中的所有硬编码路径（如 "Cydia.app"、"MobileSubstrate"），必须在代码中进行**异或 (XOR)** 加密处理，只在运行时进行动态解密，验证完毕后立即销毁内存记录。

### 2. 反调试与反附加拦截 (Anti-Debugging)
- **能力描述**：阻止攻击者使用 LLDB 等工具进行动态调试。
- **技术要求**：调用 Darwin API `ptrace(PT_DENY_ATTACH, 0, 0, 0)` 拒绝调试器附加，并结合 `sysctl` 读取进程的 `P_TRACED` 标志位，判断当前是否处于被跟踪状态。

---

## 模块三：隐匿性与抗爆破设计 (Stealth Design)
本模块指导代码层面的命名规范与执行流设计，增加逆向人员定位代码的成本。

### 1. 去特征化的 API 命名
- **能力描述**：隐藏安全组件的真实意图。
- **技术要求**：暴露给业务层的对外接口需具备迷惑性，例如命名为 `EnvironmentConfig.checkDeviceIntegrity()` 或隐藏在缓存清理类的初始化逻辑中，严禁出现 `isJailbroken` 等字眼。

### 2. 调用栈混淆 (Inline 展开)
- **能力描述**：破坏逆向工具生成的伪代码逻辑树。
- **技术要求**：针对底层的核心探测函数（如调用 `stat` 的封装层），使用 Swift 的 `@inline(__always)` 关键字强制内联，将函数体直接展开到调用处，使得汇编代码变得冗长且难以梳理。

---

## 模块四：策略出口与暗记号机制 (Strategy & Output)
本模块定义 Framework 与业务层（如网络请求组件）的交互方式。

### 1. 延迟惩罚与暗记号生成
- **能力描述**：发现异常时不采取任何中断进程的动作（如 `exit(0)`）。
- **技术要求**：在内部整合模块一的检测结果，生成一个 `environmentScore`（环境风险分值）或一段加密 **Token（暗记号）** 保留在内存中。

### 2. 业务层无缝接入出口
- **能力描述**：将安全判定权交接给后端服务器。
- **技术要求**：提供一个安全提取“暗记号”的只读属性。允许业务层（如 `NetworkManager`）在发起支付、登录等核心请求时，将其附加在 **HTTP Header** 中，由服务端拦截高危操作。