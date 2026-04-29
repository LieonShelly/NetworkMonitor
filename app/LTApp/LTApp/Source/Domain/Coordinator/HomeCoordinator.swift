//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class HomeCoordinator: Coordinator, ObservableObject, Sendable {
    @Published var path: NavigationPath = .init()
    var children: [any Coordinator] = []
    let appDataService: any AppDataWithAuthorizationServiceful
    let notificationHandler: any NotificationHandlingType
    
    init(appDataService: any AppDataWithAuthorizationServiceful, notificationHandler: any NotificationHandlingType) {
        self.appDataService = appDataService
        self.notificationHandler = notificationHandler
        let userHomeCoordinator = UserHomeCoordinator(
            appDataService: appDataService,
            notificationHandler: notificationHandler
        )
        addChild(userHomeCoordinator, isSameStack: true)
    }
    
    func build(_ route: any Route) -> AnyView? {
        guard let route = route as? HomeRoute else {
            return buildChild(route: route)
        }
        switch route {
        case .home:
            return AnyView(AppHomeView(viewModel: .init(service: appDataService, notificationHandler: notificationHandler)))
        case .questionLib:
            return AnyView(QuestionLibView(viewModel: QuestionLibViewModel(service: appDataService)))
        case .questioDetail:
            return AnyView(QuestionLibView(viewModel: QuestionLibViewModel(service: appDataService)))
        case let .reflectionDetail(question):
            return AnyView(ReflectionDetailView(viewModel: .init(service: appDataService, question: question)))
        case let .addNewAnswer(question):
            return AnyView(
                AnwserQuestionView(viewModel: .init(question: question, service: appDataService))
            )
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
    case reflectionDetail(question: Question)
    case addNewAnswer(question: Question)
}


struct TodayAnswerPageParam: Hashable, Equatable, @unchecked Sendable {
    var id: String = UUID().uuidString
    let questions: [Question]
    let submiited: (() -> Void)?
    
    static func == (lhs: TodayAnswerPageParam, rhs: TodayAnswerPageParam) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
