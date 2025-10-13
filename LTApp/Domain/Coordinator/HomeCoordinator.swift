//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class HomeCoordinator: Coordinator, ObservableObject, Sendable {
    @Published var path: NavigationPath = .init()
    var children: [any Coordinator] = []
    private let appDataService: any AppDataWithAuthorizationServiceful
    
    init(appDataService: any AppDataWithAuthorizationServiceful) {
        self.appDataService = appDataService
        let historyCoordinator = PreHomeCoordinator(appDataService: appDataService)
        addChild(historyCoordinator, isSameStack: true)
    }
    
    func build(_ route: any Route) -> AnyView? {
        guard let route = route as? HomeRoute else {
            return buildChild(route: route)
        }
        switch route {
        case .home:
            return AnyView(AppHomeView(service: appDataService))
        case .questionLib:
            return AnyView(QuestionLibView(viewModel: QuestionLibViewModel()))
        case .questioDetail:
            return AnyView(QuestionLibView(viewModel: QuestionLibViewModel()))
        }
    }
    
    func start() {
        path = .init()
        path.append(HomeRoute.home)
    }
}

enum HomeRoute: Route {
    case home
    case questionLib
    case questioDetail
}


enum HistoryRoute: Route {
    case list
}
