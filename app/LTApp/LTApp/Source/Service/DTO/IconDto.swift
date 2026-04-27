//
//  IconGeneratingStatus 2.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/1.
//

import Foundation

public enum IconGeneratingStatus: String, Codable, Sendable {
    case pending = "PENDING"
    case generated = "GENERATED"
    case failed = "FAILED"
}

public struct IconDto: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case status
        case url
        case id
        case readAt = "read_at"
    }
    let status: IconGeneratingStatus?
    let url: String?
    let id: String?
    let readAt: String?
}
