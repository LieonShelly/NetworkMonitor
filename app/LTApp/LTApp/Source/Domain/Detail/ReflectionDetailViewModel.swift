//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class ReflectionDetailViewModel: ObservableObject, @unchecked Sendable {
    
    @MainActor @Published var history: History?
    @MainActor @Published var sumary: ReflectionSummary?
    @MainActor @Published var answers: [Answer] = []
    @MainActor @Published var title: String = ""
    @MainActor @Published var subPageRoute: InnerPageRouteState = .none
    let question: Question
    let service: any AppDataWithAuthorizationServiceful
    private let questionId: String
    
    @MainActor
    init(
        service: any AppDataWithAuthorizationServiceful,
        questionId: String,
        title: String
    ) {
        self.service = service
        self.questionId = questionId
        self.title = title
        question = Question(id: questionId, title: title)
    }
    
    func fetchData() async throws {
        let history = try await service.fetchHistoryAnswersUseCase.execute(
            questionId: questionId,
            limit: nil,
            cursor: nil
        )
        print("history:\(history)")
        await MainActor.run {
            self.history = history
            self.answers = history.answers
            self.sumary = history.summary
        }
    }
    
}


