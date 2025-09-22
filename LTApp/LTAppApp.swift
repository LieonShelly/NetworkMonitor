//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@main
struct LTAppApp: App {
    @StateObject var coordinator: AppCoordinator
    @StateObject var homeCoordinator: HomeCoordinator
    @StateObject var preHomeCoordinator: PreHomeCoordinator
    
    init() {
        try! AppFont.registerFonts()
        let enviroment = Environment.dev
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
        _coordinator = StateObject(
            wrappedValue: AppCoordinator(
                appDataService: appDataWithAuthorizationService
            )
        )
        _homeCoordinator = StateObject(wrappedValue: HomeCoordinator())
        
        _preHomeCoordinator = StateObject(wrappedValue: PreHomeCoordinator(appDataService: appDataWithAuthorizationService))
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.rootView()
        }
        .environmentObject(homeCoordinator)
        .environmentObject(coordinator)
        .environmentObject(preHomeCoordinator)
    }
}
