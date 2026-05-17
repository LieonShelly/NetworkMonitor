//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol PinQuestionUseCaseType: Sendable {
    func execute(questionId: String, pinned: Bool) async throws
}

public class PinQuestionUseCase: PinQuestionUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    
    public init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public  func execute(questionId: String, pinned: Bool) async throws {
        try await repository.pinQuestion(questionId: questionId, pinned: pinned)
    }
}
