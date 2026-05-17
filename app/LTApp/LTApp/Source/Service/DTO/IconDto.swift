//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
