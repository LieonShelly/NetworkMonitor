//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct User: Sendable {
    let qodStrategy: QodStrategy
    let lastLoginAt: Date
    let hasPinnedQuestion: Bool?
    let email: String?
    let nickname: String?
    let reportPersonaId: String?
    let reportPersona: ReportPersona?
    let reminderSlot: ReminderSlot?
}

public enum QodStrategy: String, Sendable, Equatable {
    case random = "RANDOM"
    case pinned = "PINNED"
    case mixed = "MIXED"
}

public struct ReportPersona: Sendable {
    let id: String
    let label: String
}

public enum ReminderSlot: String, Sendable, Equatable {
    case morning = "MORNING"
    case afternoon = "AFTERNOON"
    case evening = "EVENING"
}

public struct UpdateNicknameResult: Sendable {
    let nickname: String?
}

public struct ReminderResult: Sendable {
    let slot: ReminderSlot?
}
