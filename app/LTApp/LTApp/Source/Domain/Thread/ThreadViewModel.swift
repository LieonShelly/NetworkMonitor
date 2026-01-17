//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class ThreadViewModel: ObservableObject, @unchecked Sendable {
    private let service: any AppDataWithAuthorizationServiceful
    @MainActor @Published var questionList: [ThreadQuestionItem] = []
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    func fetchData() async throws {
        let questionList = try await service.threadQuestionsUseCase.execute()
        await MainActor.run {
            self.questionList = questionList
        }
    }
    
    deinit {
        print("ThreadViewModel-deint")
    }
}
