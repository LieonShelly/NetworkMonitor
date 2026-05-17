//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchQuestionsWithCategoryUseCaseType: Sendable {
    
    func execute() async throws -> [Category]
}

public class FetchQuestionsWithCategoryUseCase: FetchQuestionsWithCategoryUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> [Category] {
      try await repository.fetchQuestionsWithCategory()
    }
}
