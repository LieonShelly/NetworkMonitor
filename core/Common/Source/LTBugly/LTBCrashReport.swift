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
    public let source: Source
    public let app: App
    public let device: Device
    public let exception: Exception
    public let context: Context
    public let symbolication: LTBCrashSymbolicationMetadata
    public let threads: [ThreadInfo]
    public let binaryImages: [BinaryImage]

    enum CodingKeys: String, CodingKey {
        case crashID = "crash_id"
        case timestamp
        case source
        case app
        case device
        case exception
        case context
        case symbolication
        case threads
        case binaryImages = "binary_images"
    }

    public enum Source: String, Codable, Sendable, Equatable {
        case nsException = "ns_exception"
        case signal = "signal"
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

    public struct Context: Codable, Sendable, Equatable {
        public let userID: String?
        public let sessionID: String?
        public let deviceID: String?
        public let custom: [String: String]
        public let breadcrumbs: [Breadcrumb]

        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case sessionID = "session_id"
            case deviceID = "device_id"
            case custom
            case breadcrumbs
        }
    }

    public struct Breadcrumb: Codable, Sendable, Equatable {
        public let category: String
        public let message: String?
        public let level: String
        public let timestamp: TimeInterval
        public let metadata: [String: String]
    }

    public struct ThreadInfo: Codable, Sendable, Equatable {
        public let number: UInt64
        public let name: String?
        public let crashed: Bool
        public let frames: [Frame]
    }

    public struct Frame: Codable, Sendable, Equatable {
        public let instructionAddress: String
        public let symbol: String?
        public let imageName: String?

        enum CodingKeys: String, CodingKey {
            case instructionAddress = "instruction_address"
            case symbol
            case imageName = "image_name"
        }
    }

    public struct BinaryImage: Codable, Sendable, Equatable {
        public let name: String
        public let uuid: String?
        public let baseAddress: String
        public let size: UInt64?
        public let path: String

        enum CodingKeys: String, CodingKey {
            case name
            case uuid
            case baseAddress = "base_address"
            case size
            case path
        }
    }
}
