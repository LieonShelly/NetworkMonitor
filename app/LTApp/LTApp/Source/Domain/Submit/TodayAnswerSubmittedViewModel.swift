//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
    
    func queryCurrenntIconStatus() {
        Task.detached {
            guard self.answer.icon?.status == .pending else { return }
            guard let iconId = self.answer.icon?.iconId else { return }
            let streams = self.service.queryIconStatusUseCase.execute(iconId)
            for try await stream in streams {
                if stream.status == .generated {
                    let icon = stream.toDomain()
                    await MainActor.run {
                        var oldIcon = self.answer.icon
                        oldIcon?.url = icon.url
                        oldIcon?.status = .generated
                        self.answer.icon = oldIcon
                    }
                    await self.markIconAsRead(icon)
                }
            }
        }
    }
}
