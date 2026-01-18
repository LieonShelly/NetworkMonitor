//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

typealias QuestionID = String
typealias DidTapShowMore = Bool

final class ThreadViewModel: ObservableObject, @unchecked Sendable, @preconcurrency BaseViewModelType {
    @MainActor @Published var subPageRoute: InnerPageRouteState = .none
    
    let service: any AppDataWithAuthorizationServiceful
    @MainActor @Published var questionList: [ThreadQuestionItem] = []
    @MainActor @Published var showHandlingMap: [QuestionID: DidTapShowMore] = [:]
    let limit = 21
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    func fetchData() async throws {
        let questionList = try await service.threadQuestionsUseCase.execute()
       
        await MainActor.run {
            self.questionList = questionList
            for question in questionList {
                if question.answerItems.count > limit {
                    showHandlingMap[question.id] = showHandlingMap[question.id] ?? false
                }
            }
        }
    }
    
    
    func generateAddAnswerViewModel(_ question: ThreadQuestionItem) -> TodayAnswerViewModel {
        .init(service: service, questions: [question.toQuestion()]) {[weak self]  iconId in
            Task {
//                self?.contentViewModel.calendarViewModel.queryCurrenntIconStatus(iconId)
            }
        }
    }
    
    @MainActor
    func didTapShowMore(_ question: ThreadQuestionItem) {
        showHandlingMap[question.id] = !(showHandlingMap[question.id] ?? false)
    }
    
    deinit {
        print("ThreadViewModel-deint")
    }
}
