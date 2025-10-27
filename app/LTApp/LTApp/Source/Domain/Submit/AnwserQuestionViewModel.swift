//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import Foundation

@MainActor
final class AnwserQuestionViewModel: ObservableObject, @unchecked Sendable {
    private let service: any AppDataWithAuthorizationServiceful

    @MainActor @Published var question: Question?
    @MainActor @Published var answerText: String = ""
    @MainActor @Published var createAt: Date?
    
    init(question: Question,
         service: any AppDataWithAuthorizationServiceful) {
        self.service = service
        self.question = question
    }
    
    func submit() async throws {
        await MainActor.run {
            createAt = Date()
        }
        guard let createAt = createAt else { return }
        guard let question = question else { return }
        let _ = try await service.submitAnswerUseCase.execute(
            .init(
                questionId: question.id,
                content: answerText,
                createdAt: AppDateFormatter.ymdhsm.string(from: createAt)
            )
        )
    }
}
