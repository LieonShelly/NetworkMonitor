//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Darwin


@inline(__always)
func installAntiDebugAndEvaluate() -> Int {
    denyDebuggerAttach()
    return detectTracerPresence()
}


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
