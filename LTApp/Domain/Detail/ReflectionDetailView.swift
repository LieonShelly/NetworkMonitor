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
