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
    
   
    func fetchCategories() async throws {
        let categories = try await service.fetchCategoriesUseCase.execute()
        await MainActor.run {
            if !categories.isEmpty {
                self.categories = categories.map { ThreadCategoryItem(category: $0, selected: false)}
                self.categories[selectedCategoryIndex] = self.categories[selectedCategoryIndex].copyWith(selected: true)
            }
        }
    }
    
    func fetchDataInCurrentCategory() async throws {
        guard await selectedCategoryIndex < categories.count else {
            return
        }
        try await fetchDataWitCategory(categories[selectedCategoryIndex].category.id)
    }
    
    func fetchDataWitCategory(_ categoryId: String?) async throws {
        let questionList = try await service.threadQuestionsUseCase.execute(categoryId: categoryId)
        await MainActor.run {
            self.questionList = questionList
           
            for question in questionList {
                if question.otherAnswerItems.count > limit {
                    if question.otherAnswerItems.count > 21 {
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
    func selecteCategory(_ index: Int) async {
        guard index < categories.count else {
            return
        }
        categories[selectedCategoryIndex] = categories[selectedCategoryIndex].copyWith(selected: false)
        self.selectedCategoryIndex = index
        categories[index] = categories[index].copyWith(selected: true)
        try? await fetchDataWitCategory(categories[index].category.id)
    }
    
    func checkIconStatusInCurrentQuestionList(_ questionList: [ThreadQuestionItem]) {
        func checkAnswerIcon(answer: ThreadAnswerItem, questionItem: ThreadQuestionItem) {
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
        
        for questionIndex in 0 ..< questionList.count {
            let questionItem = questionList[questionIndex]
            if let latestAnswerItem = questionList[questionIndex].latestAnswerItem {
                checkAnswerIcon(answer: latestAnswerItem, questionItem: questionItem)
            }
            for answerIndex in 0 ..< questionList[questionIndex].otherAnswerItems.count {
                let answer = questionList[questionIndex].otherAnswerItems[answerIndex]
                checkAnswerIcon(answer: answer, questionItem: questionItem)
            }
        }
    }
    
    @MainActor
    private func updateIconData(currentQuestion: Question, newAnswer: Answer) {
        guard let questionIndex =  self.questionList.firstIndex(where: { $0.id == currentQuestion.id }) else { return }
        var newQuestion = questionList[questionIndex].copy()
        if newQuestion.latestAnswerItem?.answer?.id == newAnswer.id {
            newQuestion.latestAnswerItem = .init(type: .noraml(newAnswer))
        }
        if let answerIndex = newQuestion.otherAnswerItems.firstIndex(where: { $0.answer?.id == newAnswer.id }) {
            newQuestion.otherAnswerItems[answerIndex] = .init(type: .noraml(newAnswer))
        }
        questionList[questionIndex] = newQuestion
    }
    
    deinit {
        print("ThreadViewModel-deint")
    }
}
