//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject, Coordinator, @unchecked Sendable {
    @Published var path: NavigationPath = .init()
    private let appDataService: any AppDataWithAuthorizationServiceful
    
    init(appDataService: any AppDataWithAuthorizationServiceful) {
        self.appDataService = appDataService
    }
    
    func start() {
        path.append(AppRoute.login)
    }
    
    func build(_ route: any Route) -> AnyView {
        guard let route = route as? AppRoute else {
            return AnyView(EmptyView())
        }
        switch route {
        case .login:
            let viewModel = AppleIDSignInViewModel(service: appDataService)
            return AnyView(AppleIDSignInView(viewModel: viewModel))
        case .splash:
            let viewModel = SplashViewModel(service: appDataService)
            return AnyView(SplashView(viewModel: viewModel))
        case .onborading:
            let viewModel = OnboardingViewModel(service: appDataService)
            return AnyView(OnboardingView(viewModel: viewModel))
        case .welcome:
            return AnyView(WelcomeView())
        case .firstQuestion:
            return AnyView(FirstQuestionView())
        case .home:
            let viewModel = AppHomeViewModel()
            return AnyView(AppHomeView(viewModel: viewModel))
        }
    }
    
    func push(_ route: any Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func goToHome() {
        path = .init()
        path.append(AppRoute.home)
    }
    
}

enum AppRoute: Route {
    case login
    case splash
    case onborading
    case welcome(_ categoryId: String)
    case firstQuestion(_ categoryId: String)
    case home
}
