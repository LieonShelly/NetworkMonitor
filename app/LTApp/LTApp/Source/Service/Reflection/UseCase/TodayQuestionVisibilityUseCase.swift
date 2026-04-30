//
//  TodayQuestionVisibilityUseCase.swift
//  LTApp
//
//  Created by OpenAI Codex.
//

import Foundation
import Persistence

public protocol TodayQuestionVisibilityUseCaseType: Sendable {
    func markTodayQuestionAnswered()
    func refreshTodayQuestionVisibility() -> Bool
}

public final class TodayQuestionVisibilityUseCase: TodayQuestionVisibilityUseCaseType, @unchecked Sendable {
    private enum StorageKey {
        static let answeredTodayQuestionDate = "calendar.answeredTodayQuestionDate"
    }

    private let storage: any KeyValueStorageType
    private var answeredDateInMemory: String?

    public init(storage: any KeyValueStorageType) {
        self.storage = storage
    }

    public func markTodayQuestionAnswered() {
        let today = Date().yyyymmdd
        answeredDateInMemory = today
        try? storage.save(value: today, key: StorageKey.answeredTodayQuestionDate)
    }

    public func refreshTodayQuestionVisibility() -> Bool {
        let today = Date().yyyymmdd
        if answeredDateInMemory == today {
            return false
        }

        let answeredDate = storage.read(StorageKey.answeredTodayQuestionDate)
        answeredDateInMemory = answeredDate
        return answeredDate != Date().yyyymmdd
    }
}
