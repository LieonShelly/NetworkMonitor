//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchCategoriesUseCaseType: Sendable {
    
    func execute() async throws -> [Category]
}

public class FetchCategoriesUseCase: FetchCategoriesUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> [Category] {
      try await repository.fetchCategories()
    }
}
