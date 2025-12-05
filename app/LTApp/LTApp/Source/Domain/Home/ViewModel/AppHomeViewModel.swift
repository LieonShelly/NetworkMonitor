//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import SwiftUI

final class AppHomeViewModel: ObservableObject,  @unchecked Sendable {
    @MainActor @Published var todayQuestions: [Question] = []
    @MainActor @Published var showTodayQuestion: Bool = true
    @MainActor @Published var subPageRoute: SubPageRouteState = .none
    
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
    
    deinit {
        print("AppHomeViewModel-deinit")
    }
    
    @MainActor
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
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
    func organize() -> [Question] {
        let count = self.todayQuestions.count
        var questions = self.todayQuestions
        guard let head = questions.first else { return [] }
       return [head] + questions[1 ..< count]
    }
    
    @MainActor
    func generateTodayViewModel() -> TodayAnswerViewModel {
        let todayAnswerViewModel = TodayAnswerViewModel(service: service, questions: todayQuestions, submitted: {[weak self] iconId in
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
}


extension AppHomeViewModel {
    enum SubPageRouteState: Equatable {
        case todayAnswer(TodayAnswerViewModel)
        case answerDetail(TodayAnswerSubmittedViewModel)
        case none
        
        static func == (lhs: SubPageRouteState, rhs: SubPageRouteState) -> Bool {
            switch (lhs, rhs) {
            case  (.todayAnswer, .todayAnswer):
                return true
            case  (.answerDetail, .answerDetail):
                return true
            case  (.none, .none):
                return true
            default:
                return false
            }
        }
    }
}
