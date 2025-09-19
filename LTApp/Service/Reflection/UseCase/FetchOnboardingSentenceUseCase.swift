//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchOnboardingSentenceUseCaseType: Sendable {
    func execute() async throws -> OnboardingSentence
}


public class FetchOnboardingSentenceUseCase: FetchOnboardingSentenceUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> OnboardingSentence {
      try await repository.fetchOnboardingSentence()
    }
}
