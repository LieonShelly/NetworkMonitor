//
//  TodayAnswerViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2025/11/6.
//

import Foundation
import Combine
import SwiftUI

final class TodayAnswerViewModel: ObservableObject, @unchecked Sendable {
    enum PageState {
        case unsubmit
        case submitted
        case notificationView
    }
    @Published var cardViewModels: [QuestionCardViewModel] = []
    @MainActor @Published var answerText: String = ""
    @MainActor @Published var createAt: Date?
    @MainActor @Published var pageState: PageState = .unsubmit
    var submittedViewModel: TodayAnswerSubmittedViewModel?
    var submitted: Bool = false
    private var submittedAction: ((_ iconId: String) -> Void)?
    let title: String
    let service: any AppDataWithAuthorizationServiceful
    private let inputQuestions: [Question]
    
    init(service: any AppDataWithAuthorizationServiceful, questions: [Question], submitted: ((_ iconId: String) -> Void)?)  {
        self.service = service
        self.inputQuestions = questions
        self.title = Date().monthDayDesc
        self.submittedAction = submitted
        for index in 0 ..< inputQuestions.count {
            let viewModel = QuestionCardViewModel(
                question: inputQuestions[index],
                index: index,
                count: inputQuestions.count) { [weak self] in
                    self?.changeToNextCard()
                }
            self.cardViewModels.append(viewModel)
        }
    }
    
    deinit {
        print("TodayAnswerViewModel-deinit")
    }
    
    func fetchData() async throws {
        let questions = try await  service.fetchTodayQuestionsUseCase.execute()
        await MainActor.run {
            for index in 0 ..< questions.count {
                let viewModel = QuestionCardViewModel(
                    question: questions[index],
                    index: index,
                    count: questions.count
                ) {[weak self] in
                    self?.changeToNextCard()
                }
                self.cardViewModels.append(viewModel)
            }
        }
    }
    
    
    func submit() async throws {
        if submitted {
            return
        }
        submitted = true
        await MainActor.run {
            createAt = Date()
        }
        guard let createAt = await createAt else { return }
        guard let question = cardViewModels.first?.question else { return }
        
        let answer = try await service.submitAnswerUseCase.execute(
            .init(
                questionId: question.id,
                content: answerText,
                createdAt: AppDateFormatter.ymdhsm.string(from: createAt)
            )
        )
        service.todayQuestionVisibilityUseCase.markTodayQuestionAnswered()
        submittedAction?(answer.icon?.iconId ?? "")
        submittedViewModel = .init(answer: answer, question: question, service: service)
        let didOpenNotification = await service.notificationFlagUseCase.fetch()
        await MainActor.run {
            if didOpenNotification {
                pageState = .submitted
            } else {
                pageState = .notificationView
            }
        }
    }
    
    @MainActor func refresh() {
        cardViewModels.first?.pushToNextCard()
    }
    
    
   @MainActor func changeToNextCard() {
       withAnimation(.smooth(duration: 0.5, extraBounce: 0)) {
           cardViewModels = cardViewModels.nextRotation()
           for (i, vm) in cardViewModels.enumerated() {
               vm.index = i
           }
       }
    }
}

extension [QuestionCardViewModel] {
    
     func rotateFromLeft(by: Int) -> [QuestionCardViewModel] {
         let moveIndex = by % count
         let rotatedElements = Array(self[moveIndex...]) + Array(self[0 ..< moveIndex]).reversed()
         return rotatedElements
     }
    
    func nextRotation() -> [QuestionCardViewModel] {
        guard count > 1 else { return self }
        return Array(self[1...] + self[..<1])
    }
}
