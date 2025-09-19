//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject, Coordinator, @unchecked Sendable {
    @Published var path: NavigationPath = .init()
    private let appDataService: any AppDataWithAuthorizationServicefull
    
    init(appDataService: any AppDataWithAuthorizationServicefull) {
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
            return AnyView(SplashView())
        case .onborading:
            return AnyView(OnboardingView())
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
    case welcome
    case firstQuestion
    case home
}
