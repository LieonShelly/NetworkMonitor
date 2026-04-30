//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import LTNetwork
import Persistence
import Combine
import Common

@MainActor
final class AppCoordinator: ObservableObject, @unchecked Sendable {
    @Published private(set) var root: AppRootType = .preHome
    let appDataService: any AppDataWithAuthorizationServiceful
    let notificationHandler: any NotificationHandlingType
    let rootViewProvider: any RootViewProviding
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(environment: AppEnvironment = .release) {
        let enviroment = environment
        let sslPinningValidator = SSLPinningValidator(
            environment: enviroment
        )
        let interceptorClient = ApiClient(
            environment: enviroment,
            interceptors: [],
            sslPinningValidator: sslPinningValidator
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
            ],
            sslPinningValidator: sslPinningValidator
        )
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
        LTLog.configure(
            .init(
                subsystem: "com.little.things",
                minimumLevel: .trace,
                environment: .production,
                sinks: [
                    LTFileLogSink()
                ])
        )
        self.inject()
        self.launch()
    }
    
    func changeRoot(_ type: AppRootType) {
        withAnimation(.easeInOut(duration: 0.5)) {
            root = type
        }
    }
    
    func rootView() -> some View {
        Group {
            switch root {
            case .preHome:
                PreHomeContentView()
            case let .home(viewModel):
                AppHomeRootView(viewModel: viewModel)
            }
        }
        .transition(.opacity)
        .id(root)
    }
    
    func launch() {
        rootViewProvider.root
            .sink { [weak self] root in
                withAnimation(.easeInOut(duration: 0.5)) {
                    self?.root = root
                }
            }
            .store(in: &cancellables)
    }
    
    func inject() {
        let appVariant = AppVariant(currentStage: .release)
        let featureToggle = FeatureToggle(appVariant: appVariant)
        InjectionValues.register(FeatureToggling.self, component: featureToggle)

        let riveResource = RiveResource()
        InjectionValues.register(RiveResourceType.self, component: riveResource)
        riveResource.preloadResources()
    }
}


enum AppRootType: Equatable, Hashable {
    case preHome
    case home(_ viewModel: AppHomeRootViewModel)
    
    var id: String {
        switch self {
        case .preHome:
            return "prehome"
        case .home:
            return "home"
        }
    }
   
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppRootType, rhs: AppRootType) -> Bool {
        switch (lhs, rhs) {
        case (.preHome, .preHome): return true
        case (.home, .home): return true
        default: return false
        }
    }
}


enum AppLog {
    static let logger = LTLog.logger(category: "app")
}
