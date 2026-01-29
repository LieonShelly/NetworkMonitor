//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import SwiftUI

final class AppHomeViewModel: @preconcurrency BaseViewModelType, ObservableObject,  @unchecked Sendable {
    @MainActor @Published var todayQuestions: [Question] = []
    @MainActor @Published var showTodayQuestion: Bool = true
    @MainActor @Published var subPageRoute: InnerPageRouteState = .none
    
    var tabbarViewModel = AppTabbarViewModel(
        items: [
            .init(
                selectedIcon: Image(.calendar),
                deselectedIcon: Image(.deselectedCalendar),
                selectedOpacity: 0
            ),
            .init(
                selectedIcon: Image(.threads),
                deselectedIcon: Image(.deselectedThread),
                selectedOpacity: 0
            ),
            .init(
                selectedIcon: Image(.insights),
                deselectedIcon: Image(.deselectedInsights),
                selectedOpacity: 0
            ),
            .init(
                selectedIcon: Image(.user),
                deselectedIcon: Image(.deselectedUser),
                selectedOpacity: 0
            )
        ])
    let contentViewModel: AppScrollContentViewModel
    private let service: any AppDataWithAuthorizationServiceful
    private let notificationHandler: any NotificationHandlingType
    private var cancellables: Set<AnyCancellable> = .init()
    
    deinit {
        print("AppHomeViewModel-deinit")
    }
    
    @MainActor
    init(service: any AppDataWithAuthorizationServiceful,
         notificationHandler: any NotificationHandlingType) {
        self.service = service
        self.notificationHandler = notificationHandler
        contentViewModel = AppScrollContentViewModel(service: service)
        
        contentViewModel.didScroll = { [weak self] progress, isToRight in
            guard let self else { return }
            self.tabbarViewModel.updateOpacity(progress, isToRight: isToRight)
        }
        contentViewModel.didEndScroll = { [weak self] index in
            guard let self else { return }
            self.tabbarViewModel.updateSelectedIndex(index)
        }
        tabbarViewModel.didTap = { [weak self] index in
            guard let self else { return }
            self.contentViewModel.scrollTo(index)
        }
       
    }
    
    func fetchData() async throws {
        let questions = try await service.fetchTodayQuestionsUseCase.execute()
        await MainActor.run {
            self.todayQuestions = questions
        }
    }
    
   @MainActor
    func observeNotification() {
        self.notificationHandler.topic.sink { [weak self] topic in
            guard let self else { return }
            switch topic {
            case .iconFinished:
                Task {
                    try? await  contentViewModel.calendarViewModel.fetchData()
                    self.selected(0)
                }
            case .todayQuestion:
                Task {
                    if todayQuestions.isEmpty {
                        try? await fetchData()
                    }
                    self.pushToAddTodayAnsnwer()
                }
            }
        }
        .store(in: &cancellables)
    }
    
    @MainActor
    func organize() -> [Question] {
        let count = self.todayQuestions.count
        let questions = self.todayQuestions
        guard let head = questions.first else { return [] }
       return [head] + questions[1 ..< count]
    }
    
    @MainActor
    func generateTodayViewModel(_ questions: [Question]) -> TodayAnswerViewModel {
        let todayAnswerViewModel = TodayAnswerViewModel(service: service, questions: questions, submitted: {[weak self] iconId in
            Task {
                self?.contentViewModel.calendarViewModel.queryCurrenntIconStatus(iconId)
                self?.showTodayQuestion = false
            }
            
        })
        return todayAnswerViewModel
    }
    
    @MainActor func selected(_ index: Int) {
        contentViewModel.scrollTo(index)
    }
    
    
    @MainActor func pushToAddTodayAnsnwer(_ question: Question? = nil) {
        if let question {
            route(.addSingleAnswer(generateTodayViewModel([question])))
        } else {
            route(.todayAnswer(generateTodayViewModel(todayQuestions)))
        }
    }
}

enum InnerPageRouteState: Equatable {
    case todayAnswer(TodayAnswerViewModel)
    case addSingleAnswer(TodayAnswerViewModel)
    case answerDetail(TodayAnswerSubmittedViewModel)
    case none
    
    static func == (lhs: InnerPageRouteState, rhs: InnerPageRouteState) -> Bool {
        switch (lhs, rhs) {
        case  (.todayAnswer, .todayAnswer):
            return true
        case  (.answerDetail, .answerDetail):
            return true
        case  (.none, .none):
            return true
        case (.addSingleAnswer, .addSingleAnswer):
            return true
        default:
            return false
        }
    }
}
