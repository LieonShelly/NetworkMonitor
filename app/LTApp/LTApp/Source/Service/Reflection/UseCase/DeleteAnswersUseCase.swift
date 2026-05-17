//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol DeleteAnswersUseCaseType: Sendable {
    func execute(answerId: String) async throws
}

public class DeleteAnswersUseCase: DeleteAnswersUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    public init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute(answerId: String) async throws {
        try await repository.deleteAnswer(answerId)
    }
}
