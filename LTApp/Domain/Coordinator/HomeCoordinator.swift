//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class HomeCoordinator: Coordinator, ObservableObject, Sendable {
    @Published var path: NavigationPath = .init()
    var children: [any Coordinator] = []
    
    func build(_ route: any Route) -> AnyView? {
        guard let route = route as? HomeRoute else {
            return buildChild(route: route)
        }
        switch route {
        case .home:
            let viewModel = AppHomeViewModel()
            return AnyView(AppHomeView(viewModel: viewModel))
        }
    }
    
    func start() {
        path = .init()
        path.append(HomeRoute.home)
    }
}

enum HomeRoute: Route {
    case home
}

