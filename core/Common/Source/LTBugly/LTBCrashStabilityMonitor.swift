//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import UIKit

final class LTBCrashStabilityMonitor: @unchecked Sendable {
    static let shared = LTBCrashStabilityMonitor()

    private let lock = NSRecursiveLock()
    private var store: LTBCrashReportStore?
    private var watchdogTimer: DispatchSourceTimer?
    private var lastForegroundDate: Date?
    private let watchdogQueue = DispatchQueue(label: "com.littlethings.ltbugly.watchdog")
    private var sampledFrameTimeouts = 0

    private init() { }

    func start(store: LTBCrashReportStore) {
        lock.lock()
        defer { lock.unlock() }
        self.store = store

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(memoryWarningReceived),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        guard watchdogTimer == nil else { return }
        let timer = DispatchSource.makeTimerSource(queue: watchdogQueue)
        timer.schedule(deadline: .now() + 2, repeating: 2)
        timer.setEventHandler { [weak self] in
            self?.pingMainThread()
        }
        timer.resume()
        watchdogTimer = timer
    }

    @objc
    private func memoryWarningReceived() {
        recordEvent(kind: .memoryPressure, details: [:])
    }

    @objc
    private func willEnterForeground() {
        lastForegroundDate = Date()
    }

    @objc
    private func didEnterBackground() {
        guard let lastForegroundDate else { return }
        let duration = Date().timeIntervalSince(lastForegroundDate)
        if duration > 25 {
            recordEvent(
                kind: .watchdogRisk,
                details: ["foreground_duration": String(format: "%.2f", duration)]
            )
        }
    }

    private func pingMainThread() {
        let sentAt = Date()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let duration = Date().timeIntervalSince(sentAt)
            if duration > 0.4 {
                sampledFrameTimeouts += 1
                self.recordEvent(
                    kind: .appHangRisk,
                    details: [
                        "main_thread_delay": String(format: "%.3f", duration),
                        "sampled_hang_count": "\(sampledFrameTimeouts)"
                    ]
                )
            }
        }
    }

    private func recordEvent(kind: LTBCrashEvent.Kind, details: [String: String]) {
        let runtime = LTBCrashContext.runtime()
        let event = LTBCrashEvent(
            id: UUID().uuidString,
            timestamp: Date().timeIntervalSince1970,
            kind: kind,
            app: runtime.app,
            device: runtime.device,
            context: LTBCrashContextStore.shared.snapshot(),
            details: details
        )
        store?.save(event)
    }
}
