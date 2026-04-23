//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

struct UserInfoDTO: Decodable {
    let qodStrategy: String
    let lastLoginAt: String?
    let hasPinnedQuestion: Bool
    let email: String?
    let nickname: String?
    let reportPersonaId: String?
    let reportPersona: ReportPersonaDTO?
    let reminderSlot: String?
    
    enum CodingKeys: String, CodingKey {
        case qodStrategy = "qod_strategy"
        case lastLoginAt = "last_login_at"
        case hasPinnedQuestion = "has_pinned_question"
        case email
        case nickname
        case reportPersonaId = "report_persona_id"
        case reportPersona = "report_persona"
        case reminderSlot = "reminder_slot"
    }
}

struct ReportPersonaDTO: Decodable {
    let id: String
    let label: String
}

extension UserInfoDTO {
    func toDomain() -> User {
        let lastLoginAt = ISO8601DateFormatter().date(from: lastLoginAt ?? "") ?? Date()
        return User(
            qodStrategy: .init(rawValue: qodStrategy) ?? .random,
            lastLoginAt: lastLoginAt,
            hasPinnedQuestion: hasPinnedQuestion,
            email: email,
            nickname: nickname,
            reportPersonaId: reportPersonaId,
            reportPersona: reportPersona.map { ReportPersona(id: $0.id, label: $0.label) },
            reminderSlot: ReminderSlot(rawValue: reminderSlot ?? "") ?? nil
        )
    }
}

// MARK: - 更新昵称响应
struct UpdateNicknameDTO: Decodable {
    let nickname: String?
}

extension UpdateNicknameDTO {
    func toDomain() -> UpdateNicknameResult {
        UpdateNicknameResult(nickname: nickname)
    }
}

// MARK: - 提醒时段响应
struct ReminderDTO: Decodable {
    let slot: String?
}

extension ReminderDTO {
    func toDomain() -> ReminderResult {
        ReminderResult(slot: ReminderSlot(rawValue: slot ?? ""))
    }
}

// MARK: - QoD Strategy Options (保持不变)
struct QodStrategyOptions: Decodable {
    let value: String
    let label: String
    let description: String
    let disabled: Bool
    let url: String?
}

extension QodStrategyOptions {
    func toDomain() -> QuestionOfTodaySettingItem {
        .init(selected: false,
              disabled: disabled,
              title: label,
              description: description,
              id: UUID(),
              qodStrategyValue: value,
              svgIconURL: url)
    }
}
