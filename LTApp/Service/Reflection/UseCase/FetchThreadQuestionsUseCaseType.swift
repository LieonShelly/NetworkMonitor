//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchThreadQuestionsUseCaseType: Sendable {
    func execute() async throws -> [ThreadQuestion]
}

public class FetchThreadQuestionsUseCase: FetchThreadQuestionsUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    public init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public  func execute() async throws -> [ThreadQuestion] {
        try await repository.fetchThreadPinnedQuestions()
    }
}

