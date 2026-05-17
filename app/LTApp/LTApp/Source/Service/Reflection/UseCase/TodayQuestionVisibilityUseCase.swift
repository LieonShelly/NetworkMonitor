//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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

    private let storage: any KeyDataStorageType
    private var answeredDateInMemory: String?

    public init(storage: any KeyDataStorageType) {
        self.storage = storage
    }

    public func markTodayQuestionAnswered() {
        let today = Date().yyyymmdd
        answeredDateInMemory = today
        if let data = today.data(using: .utf8) {
            try? storage.save(value: data, key: StorageKey.answeredTodayQuestionDate)
        }
    }

    public func refreshTodayQuestionVisibility() -> Bool {
        let today = Date().yyyymmdd
        if answeredDateInMemory == today {
            return false
        }

        guard let answeredDateData = storage.read(StorageKey.answeredTodayQuestionDate) else {
            return true
        }
        let answeredDate = String(data: answeredDateData, encoding: .utf8)
        answeredDateInMemory = answeredDate
        return answeredDate != Date().yyyymmdd
    }
}
