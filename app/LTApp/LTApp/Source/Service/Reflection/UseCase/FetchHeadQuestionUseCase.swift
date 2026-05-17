//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchHeadQuestionUseCaseType: Sendable {

  func execute(_ categorId: String) async throws -> Question
}

public class FetchHeadQuestionUseCase: FetchHeadQuestionUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute(_ categorId: String) async throws -> Question {
      try await repository.fetchHeadQuestion(categorId)
    }
}
 
