//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

typealias QuestionID = String
typealias DidTapShowMore = Bool

final class ThreadViewModel: ObservableObject, @unchecked Sendable {
    private let service: any AppDataWithAuthorizationServiceful
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
                    showHandlingMap[question.id] = false
                }
            }
        }
    }
    
    deinit {
        print("ThreadViewModel-deint")
    }
}
