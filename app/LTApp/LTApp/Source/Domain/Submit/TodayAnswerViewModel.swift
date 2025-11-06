//
//  TodayAnswerViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2025/11/6.
//

import Foundation
import Combine

final class TodayAnswerViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published var questions: [Question] = []
    
    private let service: any AppDataWithAuthorizationServiceful
    private let inputQuestions: [Question]
    
    init(service: any AppDataWithAuthorizationServiceful, questions: [Question])  {
        self.service = service
        self.inputQuestions = questions
    }
    
    func initializeData() async {
        await MainActor.run {
            self.questions = inputQuestions
        }
    }
    
    func fetchData() async throws {
        let questions = try await  service.fetchTodayQuestionsUseCase.execute()
        await MainActor.run {
            self.questions = questions
        }
    }
}
