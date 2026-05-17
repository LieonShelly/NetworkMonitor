//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import UIKit

final class LTBCrashAppStateTracker: @unchecked Sendable {
    static let shared = LTBCrashAppStateTracker()

    private let lock = NSRecursiveLock()
    private var stateFileURL: URL?
    private var didStart = false

    private init() { }

    func start(directoryURL: URL) {
        lock.lock()
        defer { lock.unlock() }
        guard didStart == false else { return }
        didStart = true

        stateFileURL = directoryURL.appendingPathComponent("app-state.json")
        writeState(isCleanExit: false, lastAppState: currentAppStateName())

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func consumePreviousAbnormalTermination() -> LTBCrashEvent? {
        lock.lock()
        defer { lock.unlock() }

        guard let stateFileURL,
              let data = try? Data(contentsOf: stateFileURL),
              let state = try? JSONDecoder().decode(State.self, from: data),
              state.isCleanExit == false
        else {
            return nil
        }

        let runtime = LTBCrashContext.runtime()
        let event = LTBCrashEvent(
            id: UUID().uuidString,
            timestamp: Date().timeIntervalSince1970,
            kind: .abnormalTermination,
            app: runtime.app,
            device: runtime.device,
            context: LTBCrashContextStore.shared.snapshot(),
            details: [
                "last_app_state": state.lastAppState,
                "last_update_at": String(state.updatedAt)
            ]
        )

        writeState(isCleanExit: true, lastAppState: currentAppStateName())
        return event
    }

    @objc
    private func willTerminate() {
        writeState(isCleanExit: true, lastAppState: currentAppStateName())
    }

    @objc
    private func didEnterBackground() {
        writeState(isCleanExit: false, lastAppState: "background")
    }

    @objc
    private func willEnterForeground() {
        writeState(isCleanExit: false, lastAppState: "foreground")
    }

    private func currentAppStateName() -> String {
        switch UIApplication.shared.applicationState {
        case .active:
            return "active"
        case .inactive:
            return "inactive"
        case .background:
            return "background"
        @unknown default:
            return "unknown"
        }
    }

    private func writeState(isCleanExit: Bool, lastAppState: String) {
        guard let stateFileURL else { return }
        let state = State(
            isCleanExit: isCleanExit,
            lastAppState: lastAppState,
            updatedAt: Date().timeIntervalSince1970
        )

        do {
            try FileManager.default.createDirectory(
                at: stateFileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(state)
            try data.write(to: stateFileURL, options: .atomic)
        } catch {
            assertionFailure("Failed to persist app state: \(error)")
        }
    }
}

private struct State: Codable {
    let isCleanExit: Bool
    let lastAppState: String
    let updatedAt: TimeInterval
}
