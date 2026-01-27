//
//  DeleteAnswersUseCaseType.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/27.
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
