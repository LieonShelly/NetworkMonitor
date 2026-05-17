//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

struct AppScrollContentView: View {
    @ObservedObject var viewModel: AppScrollContentViewModel
    @EnvironmentObject var tabbarVisibility: TabbarVisibility
    let addAction: (([Question]) -> Void)?
    let onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?
    
    init(viewModel: AppScrollContentViewModel,
         addAction: (([Question]) -> Void)?,
         onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?) {
        self.viewModel = viewModel
        self.addAction = addAction
        self.onTapAnswerAction = onTapAnswerAction
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .zero) {
                    CalendarView(viewModel: viewModel.calendarViewModel, addAction: addAction, onTapAnswerAction: onTapAnswerAction)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .id(0)
                    ThreadView(viewModel: viewModel.threadViewModel,
                               addAnswerAction: addAction,
                               onTapAnswerAction: onTapAnswerAction, )
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .id(1)
                    InsightsView(viewModel: viewModel.insightsViewModel)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .id(2)
                    NewUserHomeView(viewModel: viewModel.userViewModel)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .id(3)
                }
            }
            .scrollPosition($viewModel.scrollPosition)
            .scrollTargetBehavior(.paging)
            .scrollDisabled(!tabbarVisibility.isVisible)
            .onScrollGeometryChange(for: CGPoint.self, of: { $0.contentOffset }) { oldValue, newValue in
                let progress = newValue.x / proxy.size.width
                viewModel.updateScrollProgress(progress)
            }
            .onScrollPhaseChange { oldPhase, newPhase in
                switch newPhase {
                case .idle:
                    viewModel.updateSelectedIndex()
                default: break
                }
            }
        }
       
    }
    
    var horizontalLine: some View {
        Rectangle()
            .fill(.yellow)
            .frame(width: 200, height: 10)
            .rotationEffect(.degrees(90 * viewModel.preProgress), anchor: .init(x: 1, y: 0.5))
    }
}
