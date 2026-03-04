//
//  IconView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/17.
//

import SwiftUI

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

struct AnswerIconView: View {
    var answer: Answer
    var size: CGSize = .init(width: 24, height: 24)
    
    
    init(answer: Answer, size: CGSize = .init(width: 24, height: 24)) {
        self.answer = answer
        self.size = size
    }
    
    var body: some View {
        iconView(answer, size: size)
    }
    
    @ViewBuilder
    func iconView(_ answer: Answer, size: CGSize = .init(width: 24, height: 24)) -> some View {
      
        IconView(iconData: answer.icon, size: size)
    }
}

struct IconView: View {
    var iconData: IconData?
    var size: CGSize = .init(width: 24, height: 24)
    
    
    init(iconData: IconData?, size: CGSize = .init(width: 24, height: 24)) {
        self.iconData = iconData
        self.size = size
    }
    
    var body: some View {
        iconView(iconData, size: size)
    }
    
    @ViewBuilder
    func iconView(_ iconData: IconData?, size: CGSize = .init(width: 24, height: 24)) -> some View {
      
        if let icon = iconData {
            switch icon.status {
            case .pending:
                Image(.lock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            default:
                if let url = icon.url {
                    ThumbnailIconImageView(url: url) {
                        placeholderIcon
                    }
                    .frame(width: size.width, height: size.height)
                } else {
                    placeholderIcon
                        .frame(width: size.width, height: size.height)
                }
            }
        } else {
            placeholderIcon
                .frame(width: size.width, height: size.height)
        }
    }
    
    var placeholderIcon: some View {
        Circle()
            .fill(Color.clear)
            .overlay(content: {
                Image(.calendarDripper)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
    }
}
