//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol UpdateNicknameUseCaseType: Sendable {
    func execute(nickname: String?) async throws -> UpdateNicknameResult
}

public class UpdateNicknameUseCase: UpdateNicknameUseCaseType, @unchecked Sendable {
    private let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        self.repository = repository
    }
    
    public func execute(nickname: String?) async throws -> UpdateNicknameResult {
        try await repository.updateNickname(nickname)
    }
}
