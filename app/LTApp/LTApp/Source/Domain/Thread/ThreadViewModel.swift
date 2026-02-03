//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import Foundation

typealias QuestionID = String
typealias DidTapShowMore = Bool
typealias IconID = String
final class ThreadViewModel: ObservableObject, @unchecked Sendable, @preconcurrency BaseViewModelType {
    let service: any AppDataWithAuthorizationServiceful
    @MainActor @Published var subPageRoute: InnerPageRouteState = .none
    @MainActor @Published var questionList: [ThreadQuestionItem] = []
    @MainActor @Published var showHandlingMap: [QuestionID: DidTapShowMore] = [:]
    @MainActor @Published var categories: [ThreadCategoryItem] = []
    @MainActor @Published var selectedCategoryIndex: Int = 0
    var iconViewModels: [IconID: IconViewModel] = [:]
    
    let limit = 21
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    func fetchData() async throws {
        let categories = try await service.fetchCategoriesUseCase.execute()
        let questionList = try await service.threadQuestionsUseCase.execute(categoryId: categories.first?.id)
        
        await MainActor.run {
            self.questionList = questionList
            self.categories = categories.map { ThreadCategoryItem(category: $0, selected: false)}
            if !categories.isEmpty {
                self.categories[selectedCategoryIndex] = self.categories[selectedCategoryIndex].copyWith(selected: true)
            }
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
        
       self.checkIconStatusInCurrentQuestionList(questionList)
    }
    

    @MainActor
    func didTapShowMore(_ question: ThreadQuestionItem) {
        showHandlingMap[question.id] = !(showHandlingMap[question.id] ?? false)
    }
    
    @MainActor
    func selecteCategory(_ index: Int) {
        guard index < categories.count else {
            return
        }
        categories[selectedCategoryIndex] = categories[selectedCategoryIndex].copyWith(selected: false)
        self.selectedCategoryIndex = index
        categories[index] = categories[index].copyWith(selected: true)
    }
    
    
    func checkIconStatusInCurrentQuestionList(_ questionList: [ThreadQuestionItem]) {
        for questionIndex in 0 ..< questionList.count {
            for answerIndex in 0 ..< questionList[questionIndex].answerItems.count {
                let questionItem = questionList[questionIndex]
                let answer = questionList[questionIndex].answerItems[answerIndex]
                switch answer.type {
                case .noraml(let answer):
                    if let icon = answer.icon, icon.status == .pending,
                       let iconId = answer.icon?.iconId {
                        if iconViewModels[iconId] == nil {
                            let iconViewModel = IconViewModel(answer: answer, qustion: questionItem.toQuestion(), service: service)
                            iconViewModel.monitorSingleIcon(iconId) { @MainActor currentQuestion, answert in
                                self.updateIconData(currentQuestion: currentQuestion, newAnswer: answert)
                            }
                        }
                    }
                default: break
                }
            }
        }
    }
    
    
    @MainActor
    private func updateIconData(currentQuestion: Question, newAnswer: Answer) {
        guard let questionIndex =  self.questionList.firstIndex(where: { $0.id == currentQuestion.id }) else { return }
        var newQuestion = questionList[questionIndex]
        guard let answerIndex = newQuestion.answerItems.firstIndex(where: { $0.answer?.id == newAnswer.id }) else { return }
        newQuestion.answerItems[answerIndex] = .init(type: .noraml(newAnswer))
        questionList[questionIndex] = newQuestion
    }
    deinit {
        print("ThreadViewModel-deint")
    }
}
