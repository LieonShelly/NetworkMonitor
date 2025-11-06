
//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchTodayQuestionsUseCaseType: Sendable {
    func execute() async throws -> [Question]
}

public class FetchTodayQuestionsUseCase: FetchTodayQuestionsUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    public init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> [Question] {
        try await repository.fetchTodayQuestions()
    }
}
