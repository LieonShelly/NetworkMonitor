//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Darwin
import Foundation

enum LTBCrashThreadCollector {
    private static let maxFrameCount = 64

    static func collectAllThreads() -> [LTBCrashReport.ThreadInfo] {
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0

        guard task_threads(mach_task_self_, &threadList, &threadCount) == KERN_SUCCESS,
              let threadList
        else {
            return [
                .init(
                    number: UInt64(mach_thread_self()),
                    name: currentThreadName(),
                    crashed: true,
                    frames: currentThreadFrames()
                )
            ]
        }

        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: threadList),
                vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.stride)
            )
        }

        let currentThread = mach_thread_self()
        defer { mach_port_deallocate(mach_task_self_, currentThread) }

        let buffer = UnsafeBufferPointer(start: threadList, count: Int(threadCount))
        return buffer.map { thread in
            let isCurrent = thread == currentThread
            return .init(
                number: UInt64(thread),
                name: threadName(for: thread),
                crashed: isCurrent,
                frames: isCurrent ? currentThreadFrames() : frames(for: thread)
            )
        }
    }

    private static func currentThreadFrames() -> [LTBCrashReport.Frame] {
        var buffer = Array<UnsafeMutableRawPointer?>(repeating: nil, count: maxFrameCount)
        let count = backtrace(&buffer, Int32(buffer.count))
        return buffer.prefix(Int(count)).compactMap { pointer in
            frame(from: UInt64(UInt(bitPattern: pointer)))
        }
    }

    private static func frames(for thread: thread_t) -> [LTBCrashReport.Frame] {
        guard thread_suspend(thread) == KERN_SUCCESS else { return [] }
        defer { thread_resume(thread) }

        var state = arm_thread_state64_t()
        var stateCount = mach_msg_type_number_t(
            MemoryLayout<arm_thread_state64_t>.stride / MemoryLayout<natural_t>.stride
        )
        let result = withUnsafeMutablePointer(to: &state) { pointer in
            pointer.withMemoryRebound(to: natural_t.self, capacity: Int(stateCount)) {
                thread_get_state(
                    thread,
                    thread_state_flavor_t(ARM_THREAD_STATE64),
                    $0,
                    &stateCount
                )
            }
        }

        guard result == KERN_SUCCESS else { return [] }

        var addresses: [UInt64] = []
        if state.__pc != 0 {
            addresses.append(state.__pc)
        }
        if state.__lr != 0 {
            addresses.append(state.__lr)
        }

        var framePointer = state.__fp
        for _ in 0 ..< maxFrameCount {
            guard framePointer != 0 else { break }

            var stackFrame = StackFrame()
            var readSize: vm_size_t = 0
            let status = withUnsafeMutablePointer(to: &stackFrame) { pointer in
                vm_read_overwrite(
                    mach_task_self_,
                    vm_address_t(framePointer),
                    vm_size_t(MemoryLayout<StackFrame>.size),
                    vm_address_t(UInt(bitPattern: pointer)),
                    &readSize
                )
            }

            guard status == KERN_SUCCESS,
                  readSize == vm_size_t(MemoryLayout<StackFrame>.size),
                  stackFrame.returnAddress != 0,
                  stackFrame.previousFramePointer > framePointer
            else {
                break
            }

            addresses.append(stackFrame.returnAddress)
            framePointer = stackFrame.previousFramePointer
        }

        return addresses.compactMap(frame(from:))
    }

    private static func frame(from address: UInt64) -> LTBCrashReport.Frame? {
        guard address != 0 else { return nil }

        var info = Dl_info()
        let pointer = UnsafeRawPointer(bitPattern: UInt(address))
        let symbolFound = pointer.map { dladdr($0, &info) } ?? 0

        let imageName = (symbolFound != 0).flatMap {
            info.dli_fname.map { String(cString: $0).split(separator: "/").last.map(String.init) }
        } ?? nil
        let symbolName = (symbolFound != 0).flatMap {
            info.dli_sname.map { String(cString: $0) }
        } ?? nil

        return .init(
            instructionAddress: String(format: "0x%016llx", address),
            symbol: symbolName,
            imageName: imageName
        )
    }

    private static func currentThreadName() -> String? {
        threadName(for: mach_thread_self())
    }

    private static func threadName(for thread: thread_t) -> String? {
        guard let pthread = pthread_from_mach_thread_np(thread) else { return nil }
        var buffer = [CChar](repeating: 0, count: 64)
        guard pthread_getname_np(pthread, &buffer, buffer.count) == 0,
              buffer.first != 0
        else {
            return nil
        }
        return String(cString: buffer)
    }

    private struct StackFrame {
        var previousFramePointer: UInt64 = 0
        var returnAddress: UInt64 = 0
    }
}

private extension Bool {
    func flatMap<T>(_ transform: () -> T?) -> T? {
        self ? transform() : nil
    }
}
