//
//  AntiDebug.swift
//  LTCommon
//
//  Created by Renjun Li on 2026/4/28.
//

import Darwin

// MARK: - Anti-Debugging

/// 反调试模块：
///   1. Release 模式下调用 ptrace(PT_DENY_ATTACH) 拒绝调试器附加
///   2. 通过 sysctl 检测 P_TRACED 标志位，若被跟踪累加 50 分
@inline(__always)
func installAntiDebugAndEvaluate() -> Int {
    denyDebuggerAttach()
    return detectTracerPresence()
}

// MARK: - ptrace: Deny Attach

/// 调用 ptrace(PT_DENY_ATTACH) 使调试器无法附加到当前进程。
/// Debug 构建下跳过，避免开发时崩溃。
@inline(__always)
private func denyDebuggerAttach() {
#if !DEBUG
    // 通过 dlsym 动态查找 ptrace，避免 Swift 编译器找不到符号
    // 同时也不会在 import table 中留下明文 "ptrace" 引用，更具隐蔽性
    // PT_DENY_ATTACH = 31
    typealias PtraceType = @convention(c) (Int32, pid_t, caddr_t?, Int32) -> Int32
    if let sym = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "ptrace"),
       let fn = unsafeBitCast(sym, to: PtraceType?.self) {
        _ = fn(31, 0, nil, 0)
    }
#endif
}

// MARK: - sysctl: Detect P_TRACED

/// 读取当前进程的 kinfo_proc 结构，检查 P_TRACED 标志位。
/// P_TRACED 被置位表示进程正处于调试器跟踪状态。
@inline(__always)
private func detectTracerPresence() -> Int {
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride

    let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
    guard result == 0 else { return 0 }

    // P_TRACED = 0x00000800
    let isTraced = (info.kp_proc.p_flag & P_TRACED) != 0
    return isTraced ? 50 : 0
}
