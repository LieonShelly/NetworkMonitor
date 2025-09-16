//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct AppScrollContentView: View {
    @ObservedObject var viewModel: AppScrollContentViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .zero) {
                    CalendarView()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .id(0)
                    
                    ThreadView()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .id(1)
                }
//                .overlay {
//                    horizontalLine
//                }
            }
            .scrollPosition($viewModel.scrollPosition)
            .animation(.easeInOut, value: viewModel.scrollPosition)
            .scrollTargetBehavior(.paging)
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




#Preview {
    AppScrollContentView(viewModel: .init())
}
