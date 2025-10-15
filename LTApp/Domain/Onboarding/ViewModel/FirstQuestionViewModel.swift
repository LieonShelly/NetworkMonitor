//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import Foundation

final class FirstQuestionViewModel: ObservableObject, @unchecked Sendable {
    private let service: any AppDataWithAuthorizationServiceful
    @Published  private(set) var category: Category
    @MainActor @Published var question: Question?
    @MainActor @Published var answerText: String = ""
    @MainActor @Published var createAt: Date?
    
    init(category: Category, service: any AppDataWithAuthorizationServiceful) {
        self.category = category
        self.service = service
    }
    
    func fetchData() async {
        do {
            let categoryId = category.id
            let question =  try await service.fetchHeadQuestionUseCase.execute(categoryId)
            await MainActor.run {
                self.question = question
            }
        } catch {
            print(error)
        }
    }
    
    
    func submit() async throws {
        await MainActor.run {
            createAt = Date()
        }
        guard let createAt = await createAt else { return }
        guard let question = await question else { return }
        let _ = try await service.submitAnswerUseCase.execute(
            .init(
                questionId: question.id,
                content: answerText,
                createdAt: AppDateFormatter.ymdhsm.string(from: createAt)
            )
        )
    }
    
}

