//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol AppDataWithAuthorizationServicefull {
    var authUseCasse: any AuthUseCaseType { get }
}


public protocol AppDataWithoutAuthorizationServicefull {
    var refreshTokenUseCase: any RefreshTokenUseCaseType { get }
}


public final class AppDataWithoutAuthorizationService: AppDataWithoutAuthorizationServicefull, @unchecked Sendable {
   private let sessionDataRepository: SessionDataRepositoryType
    
    init(sessionDataRepository: any SessionDataRepositoryType) {
        self.sessionDataRepository = sessionDataRepository
    }
    
    public lazy var refreshTokenUseCase: any RefreshTokenUseCaseType = {
        RefreshTokenUseCase(repository: sessionDataRepository)
    }()
}


public final class AppDataWithAuthorizationService: AppDataWithAuthorizationServicefull, @unchecked Sendable {
   private let authRepository: AuthRepositoryType
    
    init(authRepository: any AuthRepositoryType) {
        self.authRepository = authRepository
    }
    
    public lazy var authUseCasse: any AuthUseCaseType = {
        AuthUseCase(repository: authRepository)
    }()
}
