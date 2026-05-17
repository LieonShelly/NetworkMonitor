//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

enum LTBCrashReportBuilder {
    static func makeNSExceptionReport(
        name: String,
        reason: String,
        callStackSymbols: [String]
    ) -> LTBCrashReport {
        let runtime = LTBCrashContext.runtime()
        let threads = LTBCrashThreadCollector.collectAllThreads()
        let binaryImages = LTBCrashBinaryImageCollector.collect()
        let context = LTBCrashContextStore.shared.snapshot()
        let symbolication = makeSymbolicationMetadata(app: runtime.app, binaryImages: binaryImages)

        return LTBCrashReport(
            crashID: UUID().uuidString,
            timestamp: Date().timeIntervalSince1970,
            source: .nsException,
            app: runtime.app,
            device: runtime.device,
            exception: .init(
                type: "NSException",
                name: name,
                reason: reason
            ),
            context: context,
            symbolication: symbolication,
            threads: mergePrimaryCallStackIfNeeded(callStackSymbols, into: threads),
            binaryImages: binaryImages
        )
    }

    static func makeSignalContextTemplate() -> LTBCrashReport {
        let runtime = LTBCrashContext.runtime()
        return LTBCrashReport(
            crashID: UUID().uuidString,
            timestamp: Date().timeIntervalSince1970,
            source: .signal,
            app: runtime.app,
            device: runtime.device,
            exception: .init(type: "signal", name: "signal", reason: "signal"),
            context: LTBCrashContextStore.shared.snapshot(),
            symbolication: makeSymbolicationMetadata(app: runtime.app, binaryImages: LTBCrashBinaryImageCollector.collect()),
            threads: [],
            binaryImages: LTBCrashBinaryImageCollector.collect()
        )
    }

    static func makeSignalContextPayload() -> LTBCrashSignalContextPayload {
        let runtime = LTBCrashContext.runtime()
        return .init(
            crashID: UUID().uuidString,
            app: runtime.app,
            device: runtime.device,
            context: LTBCrashContextStore.shared.snapshot(),
            symbolication: makeSymbolicationMetadata(app: runtime.app, binaryImages: LTBCrashBinaryImageCollector.collect()),
            binaryImages: LTBCrashBinaryImageCollector.collect()
        )
    }

    private static func makeSymbolicationMetadata(
        app: LTBCrashReport.App,
        binaryImages: [LTBCrashReport.BinaryImage]
    ) -> LTBCrashSymbolicationMetadata {
        .init(
            bundleID: app.bundleID,
            version: app.version,
            build: app.build,
            binaryImageUUIDs: binaryImages.compactMap(\.uuid)
        )
    }

    private static func mergePrimaryCallStackIfNeeded(
        _ symbols: [String],
        into threads: [LTBCrashReport.ThreadInfo]
    ) -> [LTBCrashReport.ThreadInfo] {
        guard let crashedIndex = threads.firstIndex(where: \.crashed),
              threads[crashedIndex].frames.isEmpty,
              symbols.isEmpty == false
        else {
            return threads
        }

        var mutable = threads
        mutable[crashedIndex] = .init(
            number: threads[crashedIndex].number,
            name: threads[crashedIndex].name,
            crashed: true,
            frames: symbols.map {
                .init(instructionAddress: $0, symbol: nil, imageName: nil)
            }
        )
        return mutable
    }
}
