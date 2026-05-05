//
//  LTBCrashReport.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

public struct LTBCrashReport: Codable, Sendable, Equatable {
    public let crashID: String
    public let timestamp: TimeInterval
    public let app: App
    public let device: Device
    public let exception: Exception
    public let threads: [ThreadInfo]
    public let binaryImages: [BinaryImage]

    enum CodingKeys: String, CodingKey {
        case crashID = "crash_id"
        case timestamp
        case app
        case device
        case exception
        case threads
        case binaryImages = "binary_images"
    }

    public struct App: Codable, Sendable, Equatable {
        public let bundleID: String
        public let version: String
        public let build: String

        enum CodingKeys: String, CodingKey {
            case bundleID = "bundle_id"
            case version
            case build
        }
    }

    public struct Device: Codable, Sendable, Equatable {
        public let model: String
        public let os: String
    }

    public struct Exception: Codable, Sendable, Equatable {
        public let type: String
        public let name: String
        public let reason: String
    }

    public struct ThreadInfo: Codable, Sendable, Equatable {
        public let crashed: Bool
        public let frames: [String]
    }

    public struct BinaryImage: Codable, Sendable, Equatable {
        public let name: String
        public let address: String
    }
}

