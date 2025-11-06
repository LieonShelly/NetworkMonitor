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
    @MainActor @Published var answerText: String = ""
    @MainActor @Published var createAt: Date?
    private var submitted: (() -> Void)?
    var currentIndex: Int
    
    let title: String
    private let service: any AppDataWithAuthorizationServiceful
    private let inputQuestions: [Question]
    
    init(service: any AppDataWithAuthorizationServiceful, questions: [Question], submitted: (() -> Void)?)  {
        self.service = service
        self.inputQuestions = questions
        self.title = Date().monthDayDesc
        self.currentIndex = max(questions.count - 1, 0)
        self.submitted = submitted
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
    
    
    func submit() async throws {
        await MainActor.run {
            createAt = Date()
        }
        guard let createAt = await createAt else { return }
        let question = await questions[currentIndex]
        
        let _ = try await service.submitAnswerUseCase.execute(
            .init(
                questionId: question.id,
                content: answerText,
                createdAt: AppDateFormatter.ymdhsm.string(from: createAt)
            )
        )
        submitted?()
    }
}
