//
//  QueryIconGeneratingStatusUseCaseType.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/1.
//

import Foundation

public protocol QueryIconGeneratingStatusUseCaseType: Sendable {
    func execute(_ iconId: String) async throws -> AsyncThrowingStream<IconData, any Error>
}

public final class QueryIconGeneratingStatusUseCase: QueryIconGeneratingStatusUseCaseType, @unchecked Sendable {
    private let repository: any IconRepositoryType
    
    public init(repository: any IconRepositoryType) {
        self.repository = repository
    }
    
    public func execute(_ iconId: String) async throws -> AsyncThrowingStream<IconData, any Error> {
        repository.queryIconGeneratingStatus(iconId)
    }
}
