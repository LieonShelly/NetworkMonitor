//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol AppDataServiceful {
    var authUseCasse: AuthUseCaseType { get }
}

public final class AppDataService: AppDataServiceful, @unchecked Sendable {
   private let authRepository: AuthRepositoryType
    
    init(authRepository: AuthRepositoryType) {
        self.authRepository = authRepository
    }
    
    public lazy var authUseCasse: any AuthUseCaseType = {
        AuthUseCase(repository: authRepository)
    }()
}
