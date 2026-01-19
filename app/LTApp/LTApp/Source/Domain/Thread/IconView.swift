//
//  IconView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/17.
//

import SwiftUI

class IconViewModel: ObservableObject, @unchecked Sendable {
    @Published var answer: Answer
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
        guard monitoringTasks[iconId] != nil else { return }
        service.queryIconStatusUseCase.startMonitoring(iconId)
        let task = Task {
            let stream = service.queryIconStatusUseCase.statusStream(for: iconId)
            for await dto in stream {
                if dto.status == .generated || dto.status == .failed {
                    var newAnswer = answer
                    newAnswer.icon = dto.toDomain()
                    self.answer = newAnswer
                    self.monitoringTasks.removeValue(forKey: iconId)
                    await didFinish?(qustion, newAnswer)
                    return
                }
            }
        }
        monitoringTasks[iconId] = task
    }
}

struct IconView: View {
    @ObservedObject var viewModel: IconViewModel
    var size: CGSize = .init(width: 24, height: 24)
    
    
    init(viewModel: IconViewModel, size: CGSize) {
        self.viewModel = viewModel
        self.size = size
    }
    
    var body: some View {
        iconView(viewModel.answer, size: size)
    }
    
    @ViewBuilder
    func iconView(_ answer: Answer, size: CGSize = .init(width: 24, height: 24)) -> some View {
      
        if let icon = answer.icon {
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
