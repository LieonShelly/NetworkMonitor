//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class FirstQuestionViewModel: ObservableObject, @unchecked Sendable {
    private let service: any AppDataWithAuthorizationServiceful
    private(set) var categoryId: String
    @MainActor @Published var question: Question?
    @MainActor @Published var answerText: String = ""
    
    init(categoryId: String, service: any AppDataWithAuthorizationServiceful) {
        self.categoryId = categoryId
        self.service = service
    }
    
    func fetchData() async {
        do {
            let question =  try await service.fetchHeadQuestionUseCase.execute(categoryId)
            await MainActor.run {
                self.question = question
            }
        } catch {
            print(error)
        }
    }
    
    
    func submit() async {
        do {
            guard let question = await question else { return }
            let _ = try await service.submitAnswerUseCase.execute(
                .init(
                    questionId: question.id,
                    content: answerText
                )
            )
        } catch {
            print(error)
        }
    }
    
}

