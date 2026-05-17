//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//


import SwiftUI
import UIComponent

class IconViewModel: ObservableObject, @unchecked Sendable {
    var answer: Answer
    let qustion: Question
    let service: any AppDataWithAuthorizationServiceful
    @Published var iconStates: [String: IconDto] = [:]
    private var monitoringTasks: [String: Task<Void, Never>] = [:]
    
    init(answer: Answer, qustion: Question, service: any AppDataWithAuthorizationServiceful) {
        self.answer = answer
        self.service = service
        self.qustion = qustion
    }
    
    func monitorSingleIcon(_ iconId: String,  didFinish:  (@MainActor @Sendable (Question, Answer) -> Void)?) {
        guard monitoringTasks[iconId] == nil else { return }
        let task = Task.detached {
            let stream = self.service.queryIconStatusUseCase.execute(iconId)
            do {
                for try await dto in stream {
                    if dto.status == .generated || dto.status == .failed {
                       
                        self.monitoringTasks.removeValue(forKey: iconId)
                        await MainActor.run {
                            var newAnswer = self.answer
                            newAnswer.icon = dto.toDomain()
                            self.answer = newAnswer
                            didFinish?(self.qustion, newAnswer)
                        }
                        return
                    }
                }
            } catch {
                
            }
          
        }
        monitoringTasks[iconId] = task
    }
}
