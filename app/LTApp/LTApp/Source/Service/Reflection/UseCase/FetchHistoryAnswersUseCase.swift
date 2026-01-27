//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchHistoryAnswersUseCaseType: Sendable {
    func execute(questionId: String, limit: Int?, cursor: Int?) async throws -> History
}

public class FetchHistoryAnswersUseCase: FetchHistoryAnswersUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    public init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute(questionId: String, limit: Int?, cursor: Int?) async throws -> History {
        try await repository.fetchHistory(questionId: questionId, limit: limit, cursor: cursor)
    }
}

