# iOS Crash 知识分享：NSException vs Signal

## 一句话结论

- `NSException`：更偏 Objective-C/Runtime 层语义异常，通常可读性更高。
- `Signal`：更偏进程级/系统级致命错误，通常更底层、更危险。

---

## 核心理解

`signal` 类型的 crash，本质上是操作系统发给当前进程的“致命信号”，表示进程做了某种非法或危险的事情，系统决定中断它。

和 `NSException` 的区别可以这样理解：

- `NSException`  
  更像运行时/框架层面的异常，比如数组越界、`unrecognized selector`、KVC 错误这类 Objective-C 语义上的问题。
- `Signal`  
  更像系统层/进程层面的致命错误，通常已经更接近“内存、指令、CPU、进程行为异常”。

---

## 对照表

| 维度 | NSException | Signal |
| --- | --- | --- |
| 本质 | Objective-C/Runtime 层异常 | 操作系统发给进程的致命信号 |
| 常见类型 | `NSInvalidArgumentException`、`NSRangeException`、`NSInternalInconsistencyException` | `SIGABRT`、`SIGSEGV`、`SIGBUS`、`SIGILL`、`SIGFPE` |
| 常见来源 | 数组越界、`unrecognized selector`、KVC/KVO 错误、向容器插入 `nil` | 野指针访问、访问已释放对象、非法地址访问、对齐错误、非法指令、`fatalError/assert` 触发 `abort()` |
| 日志可读性 | 通常有明确 `reason`，业务语义更清晰 | 常见为地址级信息，语义更底层 |
| 是否可恢复 | 理论上可 `@try/@catch`，但业务上通常不建议恢复 | 基本不可恢复，应最小化现场逻辑并尽快终止 |
| 采集策略 | 可做相对完整上下文采集 | 现场逻辑必须最小化，尽量遵循 async-signal-safe |

---

## 在 iOS 项目里通常长什么样

### NSException 常见样子

```text
Terminating app due to uncaught exception 'NSRangeException',
reason: '*** -[__NSArrayM objectAtIndex:]: index 5 beyond bounds [0 .. 3]'
```

```text
*** Terminating app due to uncaught exception 'NSInvalidArgumentException',
reason: '-[MyViewController doSomething:]: unrecognized selector sent to instance'
```

### Signal 常见样子

```text
Thread 0 Crashed:
EXC_BAD_ACCESS (SIGSEGV)
KERN_INVALID_ADDRESS at 0x0000000000000010
```

```text
Exception Type: EXC_CRASH (SIGABRT)
Triggered by Thread: 0
```

---

## 你们当前关注的 Signal 类型

- `SIGABRT`  
  主动中止进程。常见于 `fatalError`、`assert`、未捕获异常最终触发 `abort()`。
- `SIGSEGV`  
  非法内存访问。比如野指针、访问已经释放的对象、空指针附近非法访问。
- `SIGBUS`  
  总线错误。也是内存访问类错误，常见于地址对齐问题、映射文件访问异常。
- `SIGILL`  
  非法指令。CPU 执行了无效指令，可能是代码损坏、跳到了错误地址。
- `SIGFPE`  
  算术异常。历史上叫浮点异常，也可能是除零等非法算术操作。

可以概括为一句话：`signal crash` 是“进程级致命错误”，通常比 `NSException` 更底层，也更危险。

---

## 快速判断经验

1. 有明确 `reason`、像业务/框架语义错误：优先看 `NSException`。  
2. 出现 `EXC_BAD_ACCESS`、`KERN_INVALID_ADDRESS`、疑似指针问题：优先看 `Signal`（常见 `SIGSEGV/SIGBUS`）。  
3. `fatalError/assert` 类中止：通常最终落到 `SIGABRT`。  

---

## 实践建议

- 对 `NSException`：重点看异常 `name/reason` + 触发方法栈。  
- 对 `Signal`：重点看崩溃线程地址栈、内存访问特征、二进制镜像与符号化结果。  
- Crash 采集框架设计上，`Signal` 路径要比 `NSException` 路径更保守，崩溃现场尽量只做最小落盘。  

---

## 为什么我们重视 Signal 路径

因为 `signal` 发生时，进程状态往往已经不可信了，例如：

- 栈可能损坏
- 内存可能已经乱掉
- runtime 可能处于半崩溃状态
- 再做复杂 Swift/ObjC 操作容易二次崩溃

---

## 补充概念：栈帧（Stack Frame）

### 什么是栈帧？

**栈帧就是程序在运行时，为“单个函数调用”在内存（栈区）中开辟的一块临时空间。**

每当你调用一个函数，系统就会在内存的“栈”上压入（Push）一个新的栈帧；当函数执行完毕返回时，这个栈帧就会被弹出（Pop）并销毁。

### 栈帧包含的内容

一个栈帧通常包含以下几类关键信息：

- **局部变量**：函数内部定义的变量。
- **函数参数**：传递给该函数的输入值。
- **返回地址（Return Address）**：当前函数执行完后，程序应该跳回到哪一行代码继续执行。
- **上一个栈帧的指针（Frame Pointer, FP）**：指向调用者的栈帧起始位置，从而形成一个链表。
- **保存的寄存器**：为了在函数切换时不破坏调用者的状态，需要暂时保存的一些 CPU 寄存器值。

### 为什么在崩溃分析中它很重要？

当你看到崩溃日志（Backtrace）时，那一行行的方法名其实就是由一个个**栈帧**组成的“调用链”。

在手动回溯（Stack Walking）过程中，程序就是**顺着这些栈帧的 FP 指针往回找**。它每找到一个栈帧，就读出里面记录的“返回地址”，这样就能拼凑出完整的函数调用顺序。

### 形象比喻

如果把整个程序的执行比作一次**探险**：
- **栈帧**就是你每进入一个新山洞（函数）时，在门口留下的**路标**。
- 路标上写着你进洞前的状态，以及出洞后该往哪走。
- **回溯（Stack Walking）**就是搜救队顺着这些路标逆向寻找，看你到底是怎么一步步深入到最后失踪（崩溃）那个位置的。
