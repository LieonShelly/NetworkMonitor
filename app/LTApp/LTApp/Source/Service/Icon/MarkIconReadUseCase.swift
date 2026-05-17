//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol MarkIconReadUseCaseType: Sendable {
    func execute(_ iconId: String) async throws -> IconReadResult
}

public class MarkIconReadUseCase: MarkIconReadUseCaseType, @unchecked Sendable {
    private let repository: any IconRepositoryType

    public init(repository: any IconRepositoryType) {
        self.repository = repository
    }

    public func execute(_ iconId: String) async throws -> IconReadResult {
        try await repository.markIconRead(iconId)
    }
}
