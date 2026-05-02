//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

final class ReflectionDetailViewModel: @preconcurrency BaseViewModelType, ObservableObject, @unchecked Sendable {
    
    @MainActor @Published var history: History?
    @MainActor @Published var sumary: ReflectionSummary?
    @MainActor @Published var answers: [Answer] = []
    @MainActor @Published var title: String = ""
    @MainActor @Published var subPageRoute: InnerPageRouteState = .none
    var longPressAnswer: Answer?
    let question: Question
    let service: any AppDataWithAuthorizationServiceful
    private let questionId: String
    var iconViewModels: [IconID: IconViewModel] = [:]
    
    @MainActor
    init(
        service: any AppDataWithAuthorizationServiceful,
        question: Question
    ) {
        self.service = service
        self.questionId = question.id
        self.title = question.title
        self.question = question
    }
    
    func fetchData() async throws {
        let history = try await service.fetchHistoryAnswersUseCase.execute(
            questionId: questionId,
            limit: nil,
            cursor: nil
        )
        await MainActor.run {
            self.history = history
            self.answers = history.answers
            self.sumary = history.summary
            self.checkIconStatusInCurrentQuestionList(answers)
        }
    }
    
    @MainActor
    func generateTodayViewModel(_ questions: [Question]) -> TodayAnswerViewModel {
        let todayAnswerViewModel = TodayAnswerViewModel(service: service, questions: questions, submitted: {[weak self] iconId in
            self?.queryCurrenntIconStatus(iconId)
            
        }, dismissedAction: { [weak self] in
            Task.detached {
                try? await self?.fetchData()
            }
        })
        return todayAnswerViewModel
    }
    
    func queryCurrenntIconStatus(_ iconId: String) {
        Task.detached {
            try await self.fetchData()
            let streams = self.service.queryIconStatusUseCase.execute(iconId)
            for try await _ in streams {}
            try await self.fetchData()
        }
    }
    
    func markIconAsRead(_ answer: Answer) {
        guard answer.icon?.readAt == nil else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard let icon = answer.icon, let iconId = icon.iconId else { return }
            let _ = try? await service.markIconReadUseCase.execute(iconId)
            try? await fetchData()
        }
    }
    
    func checkIconStatusInCurrentQuestionList(_ answers: [Answer]) {
        for answer in answers {
            if let icon = answer.icon, icon.status == .pending,
               let iconId = answer.icon?.iconId {
                if iconViewModels[iconId] == nil {
                    let iconViewModel = IconViewModel(answer: answer, qustion: question, service: service)
                    iconViewModel.monitorSingleIcon(iconId) { @MainActor currentQuestion, answert in
                        self.updateIconData(currentQuestion: currentQuestion, newAnswer: answert)
                    }
                }
            }
        }
    }
    
    @MainActor
    private func updateIconData(currentQuestion: Question, newAnswer: Answer) {
        guard let answerIndex = answers.firstIndex(where: { $0.id == newAnswer.id }) else { return }
        answers[answerIndex] = newAnswer.copy()
    }
    
    func deleteAnswer() async throws {
        if let longPressAnswer {
            try await service.deleteAnswerUseCase.execute(answerId: longPressAnswer.id)
            try await fetchData()
        }
    }
}

