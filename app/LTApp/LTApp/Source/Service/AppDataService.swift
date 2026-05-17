//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol AppDataWithoutAuthorizationServicefull {
    var refreshTokenUseCase: any RefreshTokenUseCaseType { get }
}

public final class AppDataWithoutAuthorizationService: AppDataWithoutAuthorizationServicefull, @unchecked Sendable {
    private let sessionDataRepository: SessionDataRepositoryType
    
    public init(sessionDataRepository: any SessionDataRepositoryType) {
        self.sessionDataRepository = sessionDataRepository
    }
    
    public lazy var refreshTokenUseCase: any RefreshTokenUseCaseType = {
        RefreshTokenUseCase(repository: sessionDataRepository)
    }()
}
