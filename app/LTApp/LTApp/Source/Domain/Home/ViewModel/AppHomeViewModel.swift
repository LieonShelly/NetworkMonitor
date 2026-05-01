//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import SwiftUI

final class AppHomeViewModel: @preconcurrency BaseViewModelType, ObservableObject,  @unchecked Sendable {
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
        
        contentViewModel.configQoTFlow {[weak self] in
            Task {
                guard let self else { return }
                guard let questions = try? await service.fetchTodayQuestionsUseCase.execute() else { return }
                await MainActor.run {
                    self.pushToAddTodayAnsnwer(questions)
                }
            }
        }
        
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
            self.selected(index)
        }
       
    }
    
   @MainActor
    func observeNotification() {
        self.notificationHandler.payload.sink { [weak self] data in
            guard let self else { return }
            switch data.topic {
            case .iconFinished:
                Task {
                    let calendarViewModel = contentViewModel.calendarViewModel
                    guard let idData = data.data?.data(using: .utf8) else { return }
                    guard let iconNotification = try? JSONDecoder().decode(IconNotificationData.self, from: idData) else { return }
                    guard let answer = try? await calendarViewModel.searchAnswer(iconNotification.answerId) else { return }
                    guard let viewModel = calendarViewModel.generateAnswerDetailViewModel(answer) else { return }
               
                    route(.answerDetail(viewModel))
                    self.selected(0)
                }
            case .todayQuestion:
                Task {
                    let calendarViewModel = contentViewModel.calendarViewModel
                    if calendarViewModel.todayQuestions.isEmpty {
                       try? await calendarViewModel.fetchDataTodayQuestions()
                    }
                    pushToAddTodayAnsnwer(calendarViewModel.organize())
                }
            case .reportReady:
                Task {
                    self.selected(2)
                    contentViewModel.insightsViewModel.router?.popToRoot()
                }
            case .thread:
                Task {
                    self.selected(1)
                }
            case .calendar:
                Task {
                    self.selected(0)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    @MainActor func pushToAddTodayAnsnwer(_ questions: [Question]) {
        guard !questions.isEmpty else { return }
        if questions.count > 1 {
            let todayAnswerViewModel = TodayAnswerViewModel(service: service, questions: questions, submitted: {[weak self] iconId in
                Task {
                    self?.queryCurrenntIconStatus(iconId)
                    self?.contentViewModel.calendarViewModel.refreshTodayQuestionVisibility()
                }
                
            })
            route(.todayAnswer(todayAnswerViewModel))
        } else {
            let todayAnswerViewModel = TodayAnswerViewModel(service: service, questions: questions, submitted: {[weak self] iconId in
                Task {
                    self?.queryCurrenntIconStatus(iconId)
                    self?.contentViewModel.calendarViewModel.refreshTodayQuestionVisibility()
                }
                
            })
            route(.addSingleAnswer(todayAnswerViewModel))
        }
    }
    
    @MainActor func selected(_ index: Int) {
        contentViewModel.scrollTo(index)
        Task.detached {
            await self.refreshSelectedTab(index)
        }
    }
    
    @MainActor
    private func refreshSelectedTab(_ index: Int) async {
        switch index {
        case 0:
            try? await contentViewModel.calendarViewModel.fetchData()
        case 1:
            if contentViewModel.threadViewModel.categories.isEmpty {
                try? await contentViewModel.threadViewModel.fetchCategories()
            }
            try? await contentViewModel.threadViewModel.fetchDataInCurrentCategory()
        case 2:
            try? await contentViewModel.insightsViewModel.fetchHistoryHeaderCurrentWeekIcons()
            try? await contentViewModel.insightsViewModel.fetchHistory()
            await contentViewModel.insightsViewModel.refreshArcadeState()
        case 3:
            try? await contentViewModel.userViewModel.fetchUserInfo()
        default:
            break
        }
    }
    
    func queryCurrenntIconStatus(_ iconId: String) {
        Task.detached {
            try await self.contentViewModel.calendarViewModel.fetchData()
            try await self.contentViewModel.threadViewModel.fetchDataInCurrentCategory()
            let streams = self.service.queryIconStatusUseCase.execute(iconId)
            for try await _ in streams {}
            try await self.contentViewModel.calendarViewModel.fetchData()
            try await self.contentViewModel.threadViewModel.fetchDataInCurrentCategory()
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

struct IconNotificationData: Codable {
    let answerId: String
    enum CodingKeys: String, CodingKey {
        case answerId = "answer_id"
    }
}
