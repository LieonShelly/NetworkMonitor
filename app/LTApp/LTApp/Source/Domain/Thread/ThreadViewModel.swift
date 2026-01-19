//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

typealias QuestionID = String
typealias DidTapShowMore = Bool

final class ThreadViewModel: ObservableObject, @unchecked Sendable, @preconcurrency BaseViewModelType {
    let service: any AppDataWithAuthorizationServiceful
    @MainActor @Published var subPageRoute: InnerPageRouteState = .none
    @MainActor @Published var questionList: [ThreadQuestionItem] = []
    @MainActor @Published var showHandlingMap: [QuestionID: DidTapShowMore] = [:]
    var iconViewModels: [String: IconViewModel] = [:]
    
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
                    if question.answerItems.count > 21 {
                        showHandlingMap[question.id] = showHandlingMap[question.id] ?? false
                    } else {
                        showHandlingMap[question.id] = nil
                    }
                }
            }
        }
    }
    

    @MainActor
    func didTapShowMore(_ question: ThreadQuestionItem) {
        showHandlingMap[question.id] = !(showHandlingMap[question.id] ?? false)
    }
    
    
    func generateIconViewModel(question: Question, answer: Answer) -> IconViewModel {
        guard let iconId = answer.icon?.iconId else {
            return IconViewModel(answer: answer, qustion: question, service: service)
        }
        if let viewModel = iconViewModels[iconId] {
            return viewModel
        }
        let viewModel = IconViewModel(answer: answer, qustion: question, service: service)
        viewModel.monitorSingleIcon(iconId) {  (currentQuestion, currentAnswer) in
            self.updateIconData(currentQuestion: currentQuestion, newAnswer: currentAnswer)
        }
        iconViewModels[iconId] = viewModel
        return viewModel
    }
    
    
    @MainActor
    private func updateIconData(currentQuestion: Question, newAnswer: Answer) {
        guard let questionIndex =  self.questionList.firstIndex(where: { $0.id == currentQuestion.id }) else { return }
        var newQuestion = questionList[questionIndex]
        guard let answerIndex = newQuestion.answerItems.firstIndex(where: { $0.id == newAnswer.id }) else { return }
        newQuestion.answerItems[answerIndex] = .init(type: .noraml(newAnswer), id: newAnswer.id)
        questionList[questionIndex] = newQuestion
    }
    deinit {
        print("ThreadViewModel-deint")
    }
}
