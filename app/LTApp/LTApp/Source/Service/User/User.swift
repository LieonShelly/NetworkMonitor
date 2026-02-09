//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct User: Sendable {
    let qodStrategy: QodStrategy
    let lastLoginAt: Date
    let hasPinnedQuestion: Bool?
    let email: String?
}

public enum QodStrategy: String, Sendable, Equatable {
    case random = "RANDOM"
    case pinned = "PINNED"
    case mixed = "MIXED"
}
