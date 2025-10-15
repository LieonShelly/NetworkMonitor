//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject, @unchecked Sendable {
    @Published private(set) var root: AppRootType = .preHome
    let appDataService: any AppDataWithAuthorizationServiceful
    
    init(environment: Environment = .dev) {
        let enviroment = environment
        let interceptorClient = ApiClient(
            environment: enviroment,
            interceptors: []
        )
        let keyChain = KeyChainStorage()
        let sessionManager = SessionService(storage: keyChain)
        let sessionRepository = SessionDataRepository(
            apiClient: interceptorClient,
            authTokenProvider: sessionManager
        )
        let appDataWithoutAuthorizationService = AppDataWithoutAuthorizationService(
            sessionDataRepository: sessionRepository
        )
        let tokenInterceptor = AuthInterceptor(tokenProvider: sessionManager)
        let refreshTokenInterceptor = RefreshTokenInterceptor(
            tokenProvider: sessionManager,
            service: appDataWithoutAuthorizationService)
        let apiClient = ApiClient(
            environment: enviroment,
            interceptors: [
                tokenInterceptor,
                refreshTokenInterceptor
            ])
        let authRepository = AuthRepository(
            apiClient: apiClient,
            authTokenProvider: sessionManager
        )
        let reflectionRepository = ReflectionRepository(apiClient: apiClient)
        let appDataWithAuthorizationService = AppDataWithAuthorizationService(
            authRepository: authRepository,
            reflectionRepository: reflectionRepository
        )
        self.appDataService = appDataWithAuthorizationService
        //changeRoot(sessionManager.refreshToken == nil ? .preHome : .home)
    }
    
    func changeRoot(_ type: AppRootType) {
        root = type
    }
    
    func rootView() -> AnyView {
        switch root {
        case .preHome:
            return AnyView(PreHomeContentView())
        case .home:
            return AnyView(AppHomeRootView())
        }
    }
}


enum AppRootType {
    case preHome
    case home
}



enum AppRoute: Route {
    
}
