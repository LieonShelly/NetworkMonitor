//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public struct LTBCrashSymbolicationMetadata: Codable, Sendable, Equatable {
    public let bundleID: String
    public let version: String
    public let build: String
    public let binaryImageUUIDs: [String]

    enum CodingKeys: String, CodingKey {
        case bundleID = "bundle_id"
        case version
        case build
        case binaryImageUUIDs = "binary_image_uuids"
    }

    public init(
        bundleID: String,
        version: String,
        build: String,
        binaryImageUUIDs: [String]
    ) {
        self.bundleID = bundleID
        self.version = version
        self.build = build
        self.binaryImageUUIDs = binaryImageUUIDs
    }
}
