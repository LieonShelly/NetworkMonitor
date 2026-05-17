//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

struct LTBCrashSignalContextPayload: Codable, Sendable, Equatable {
    let crashID: String
    let app: LTBCrashReport.App
    let device: LTBCrashReport.Device
    let context: LTBCrashReport.Context
    let symbolication: LTBCrashSymbolicationMetadata
    let binaryImages: [LTBCrashReport.BinaryImage]

    enum CodingKeys: String, CodingKey {
        case crashID = "crash_id"
        case app
        case device
        case context
        case symbolication
        case binaryImages = "binary_images"
    }
}
