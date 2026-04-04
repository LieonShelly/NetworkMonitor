//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

enum PreHomeRoute: Route {
    case login
    case splash
    case onborading
    case welcome(_ category: Category)
    case firstQuestion(_ category: Category)
}

@MainActor
final class PreHomeCoordinator: ObservableObject, Coordinator, @unchecked Sendable {
    @Published var path: NavigationPath = .init()

    var children: [any Coordinator] = []
    
    private let appDataService: any AppDataWithAuthorizationServiceful
    
    init(appDataService: any AppDataWithAuthorizationServiceful) {
        self.appDataService = appDataService
    }
    
    func start() {
        path.append(PreHomeRoute.onborading)
        appDataService.onboardingAccessUseCase.reset()
    }
    
    func build(_ route: any Route) -> AnyView? {
        guard let route = route as? PreHomeRoute else {
            return buildChild(route: route)
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
        case let .welcome(category):
            let viewModel = WelcomeViewModel(category: category)
            return AnyView(WelcomeView(viewModel: viewModel))
        case let .firstQuestion(category):
            let viewModel = FirstQuestionViewModel(
                category: category,
                service: appDataService
            )
            return AnyView(FirstQuestionView(viewModel: viewModel))
        }
    }
}
