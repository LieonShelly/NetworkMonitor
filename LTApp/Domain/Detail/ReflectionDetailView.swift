//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct ReflectionDetailView: View {
    @StateObject var viewModel: ReflectionDetailViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    init(viewModel: ReflectionDetailViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                titleView
                totalView
                LazyVStack(spacing: .zero) {
                    ForEach(viewModel.answers, id: \.id) { answer in
                        DetailAnswerRow(answer: answer)
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .defaultBackground()
        .defaultNavigationBar("") {
            homeCoordinator.pop()
        }
        .task {
            do {
                try await viewModel.fetchData()
            } catch {
                
            }
        }
    }
    
    var titleView: some View {
        Text(viewModel.title)
            .textStyle(size: 32)
            .padding(.horizontal, 42)
            .padding(.top, 10)
    }
    
    @ViewBuilder var totalView: some View {
        if let sumary = viewModel.sumary {
            Button {
                
            } label: {
                Text("\(sumary.totalAnswers) answers, \(sumary.daysOver) days ")
                    .textStyle(size: 10, color: AppColor.color(hex: 0xffffff), fontFamily: .poppinsRegular)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColor.color(hex: 0x000000))
                    }
            }
            .padding(.top, 27)
            .padding(.bottom, 24)
        }
        
    }
}

struct DetailAnswerRow: View {
    let answer: Answer
    
    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            dateView
            iconView
            textView
        }
    }
    
    var dateView: some View {
        VStack(alignment: .trailing, spacing: .zero) {
            Text(answer.createAt?.monthDesc(isShort: true) ?? "")
                .textStyle(size: 20, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
            
            Text(answer.createAt?.dayDesc() ?? "")
                .textStyle(size: 20, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
            
        }
        .frame(width: 30)
        .padding(.top, 42)
    }
    
    var iconView: some View {
        VStack(spacing: .zero) {
            Image(.calendarDripper)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            line()
                .padding(.vertical, 8)
        }
        .padding(.leading, 8)
    }
    
    var textView: some View {
        HStack {
            Text(answer.content)
                .multilineTextAlignment(.leading)
                .textStyle(size: 14, color: AppColor.color(hex: 0x6f6f6f), fontFamily: .poppinsRegular)
            Spacer()
        }
      
            .padding(.top, 42)
            .padding(.bottom, 14)
    }
    
    
    func line(segmentCount: Int = 40, seed: Int = 100) -> some View {
        WavyLine(segmentCount: segmentCount, seed: seed)
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .foregroundColor(AppColor.color(hex: 0x000000))
            .frame(width: 2)
        
    }
}


import Combine

final class ReflectionDetailViewModel: ObservableObject, @unchecked Sendable {
    
    @MainActor @Published var history: History?
    @MainActor @Published var sumary: ReflectionSummary?
    @MainActor @Published var answers: [Answer] = []
    @MainActor @Published var title: String = ""
    
    private let service: any AppDataWithAuthorizationServiceful
    private let questionId: String
    
    @MainActor
    init(
        service: any AppDataWithAuthorizationServiceful,
        questionId: String,
        title: String
    ) {
        self.service = service
        self.questionId = questionId
        self.title = title
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
        }
    }
    
}
