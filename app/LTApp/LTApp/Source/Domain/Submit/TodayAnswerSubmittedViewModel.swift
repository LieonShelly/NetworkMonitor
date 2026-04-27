//
//  TodayAnswerSubmittedViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/5.
//

import SwiftUI
import Foundation

final class TodayAnswerSubmittedViewModel: ObservableObject, @unchecked Sendable {
    @Published var answer: Answer
    @Published var question: Question
    let service: any AppDataWithAuthorizationServiceful
    let title: String
    
    init(answer: Answer, question: Question, service: any AppDataWithAuthorizationServiceful) {
        self.answer = answer
        self.question = question
        self.service = service
        self.title = answer.createYmd?.monthDayDesc ?? ""
    }
    
    func markIconAsRead(_ icon: IconData) async {
        guard let iconId = icon.iconId else { return }
        let _ = try? await service.markIconReadUseCase.execute(iconId)
    }
}
