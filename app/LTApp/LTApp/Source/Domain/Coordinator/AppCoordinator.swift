//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import LTNetwork
import Persistence
import Combine
import LTCommon

@MainActor
final class AppCoordinator: ObservableObject, @unchecked Sendable {
    @Published private(set) var root: AppRootType = .preHome
    let appDataService: any AppDataWithAuthorizationServiceful
    let notificationHandler: any NotificationHandlingType
    let rootViewProvider: any RootViewProviding
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(environment: AppEnvironment = .dev) {
        let enviroment = environment
        let interceptorClient = ApiClient(
            environment: enviroment,
            interceptors: []
        )
        let keyChain = KeyChainStorage()
        let userDefaultStorage = UserDefaultStorage()
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
        let logoutInterceptor = LogoutInterceptor(tokenProvider: sessionManager)
        let apiClient = ApiClient(
            environment: enviroment,
            interceptors: [
                tokenInterceptor,
                refreshTokenInterceptor,
                logoutInterceptor,
            ])
        let authRepository = AuthRepository(
            apiClient: apiClient,
            authTokenProvider: sessionManager
        )
        let reflectionRepository = ReflectionRepository(apiClient: apiClient)
        let iconRepository = IconRepository(apiClient: apiClient)
        let notificationRepository = NotificationRepository(apiClient: apiClient)
        let userFlowRepository = UserFlowRepository(apiClient: apiClient)
        let reportRepository = ReportRepository(apiClient: apiClient)
        let appDataWithAuthorizationService = AppDataWithAuthorizationService(
            authRepository: authRepository,
            reflectionRepository: reflectionRepository,
            userFlowRepository: userFlowRepository,
            iconRepositroy: iconRepository,
            notificationRepository: notificationRepository,
            reportRepository: reportRepository,
            storage: keyChain,
            keyDataStorage: userDefaultStorage
        )
        self.appDataService = appDataWithAuthorizationService
        self.rootViewProvider = RootViewProvider(
            tokenProvider: sessionManager,
            tokenExpired: logoutInterceptor
        )
        self.notificationHandler = NotificationHandler()
        self.inject()
        self.launch()
    }
    
    func changeRoot(_ type: AppRootType) {
        root = type
    }
    
    func rootView() -> AnyView {
        switch root {
        case .preHome:
            return AnyView(PreHomeContentView())
        case let .home(viewModel):
            return AnyView(AppHomeRootView(viewModel: viewModel))
        }
    }
    
    func launch() {
        rootViewProvider.root
            .sink { [weak self] root in
                self?.root = root
            }
            .store(in: &cancellables)
    }
    
    func inject() {
        let appVariant = AppVariant(currentStage: .release)
        let featureToggle = FeatureToggle(appVariant: appVariant)
        InjectionValues.register(FeatureToggling.self, component: featureToggle)
    }
}


enum AppRootType {
    case preHome
    case home(_ viewModel: AppHomeRootViewModel)
}


enum AppRoute: Route {
    
}


