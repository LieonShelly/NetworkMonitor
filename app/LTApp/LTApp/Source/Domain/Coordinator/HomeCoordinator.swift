//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class HomeCoordinator: Coordinator, ObservableObject, Sendable {
    @Published var path: NavigationPath = .init()
    @Published var dripleTransitionData: DrippleTransitionData!

    var children: [any Coordinator] = []
    private let appDataService: any AppDataWithAuthorizationServiceful
    private let notificationHandler: any NotificationHandlingType
    
    init(appDataService: any AppDataWithAuthorizationServiceful, notificationHandler: any NotificationHandlingType) {
        self.appDataService = appDataService
        self.notificationHandler = notificationHandler
        let historyCoordinator = PreHomeCoordinator(appDataService: appDataService)
        addChild(historyCoordinator, isSameStack: true)
    }
    
    func generateDripleTransitionData(_ namespace: Namespace.ID) {
        dripleTransitionData = .init(
            drippleAnimationSpace: namespace,
            showCalendarDripple: false,
            showDrippleClose: false,
            date: .init()
        )
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
        case let .reflectionDetail(questionId, title):
            return AnyView(ReflectionDetailView(viewModel: .init(service: appDataService, questionId: questionId, title: title)))
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
    case reflectionDetail(questionId: String, title: String)
    case addNewAnswer(question: Question)
}


enum HistoryRoute: Route {
    case list
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
