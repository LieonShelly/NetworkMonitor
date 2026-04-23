//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchReminderUseCaseType: Sendable {
    func execute() async throws -> ReminderResult
}

public class FetchReminderUseCase: FetchReminderUseCaseType, @unchecked Sendable {
    private let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> ReminderResult {
        try await repository.fetchReminder()
    }
}
