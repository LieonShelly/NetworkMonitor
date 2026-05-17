//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol SaveTimezoneUseCaseType: Sendable {
    func execute(timestamp: String) async throws -> SaveTimezoneResult
}

public class SaveTimezoneUseCase: SaveTimezoneUseCaseType, @unchecked Sendable {
    private let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        self.repository = repository
    }
    
    public func execute(timestamp: String) async throws -> SaveTimezoneResult {
        try await repository.saveTimezone(timestamp)
    }
}
