//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol UpdateReminderUseCaseType: Sendable {
    func execute(slot: ReminderSlot?) async throws -> ReminderResult
}

public class UpdateReminderUseCase: UpdateReminderUseCaseType, @unchecked Sendable {
    private let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        self.repository = repository
    }
    
    public func execute(slot: ReminderSlot?) async throws -> ReminderResult {
        try await repository.updateReminder(slot?.rawValue)
    }
}
