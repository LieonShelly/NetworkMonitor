//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct SplashView: View {
    enum CurrentPage {
        case first
        case second
        case third
    }
    @EnvironmentObject var coordinator: PreHomeCoordinator
    @State var currentPage: CurrentPage = .first
    @ObservedObject var viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.sentence != nil {
                switch currentPage {
                case .first:
                    firstScreen
                case .second:
                    secondScreen
                case .third:
                    thirdSceen
                }
            }
        }
            .defaultBackground()
            .toolbarVisibility(.hidden, for: .navigationBar)
            .task {
                await viewModel.fetchData()
            }
    }
    
    var firstScreen: some View {
        AnimatedMultilineText(
            text: viewModel.sentence?.page1st ?? "big thoughts, tiny moments.",
            font: AppFont.feltTipSenior(size: 32, fontWeight: .regular),
            width: 188) {
                currentPage = .second
            }
    }
    
    
    var secondScreen: some View {
        AnimatedMultilineText(text:  viewModel.sentence?.page2st ?? "grow your reflections into insights with guided questions", font: AppFont.feltTipSenior(size: 32, fontWeight: .regular), width: 307) {
            withAnimation(.easeInOut(duration: 1)) {
                currentPage = .third
            }
            
        }
        .transition(.asymmetric(insertion: .identity, removal: .move(edge: .leading)))
    }
    
    var icons: [ImageResource] = [
        .necktie, .heart, .flower, .fire,
        .cup, .mail, .sun, .smile
    ]
    @State var visibleIcons: Int = 0
    var thirdSceen: some View {
        VStack(spacing: .zero) {
            Text(viewModel.sentence?.page3st ?? "each answer will generate a unique icon of your own ")
                .multilineTextAlignment(.leading)
                .lineLimit(10)
                .frame(width: 335)
                .font(AppFont.feltTipSenior(size: 32, fontWeight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .padding(.bottom, 172)
                .padding(.top, 114)
            
            LazyVGrid(columns: [
                .init(.fixed(18), spacing: 40, alignment: .center),
                .init(.fixed(18), spacing: 40, alignment: .center),
                .init(.fixed(18), spacing: 40, alignment: .center),
                .init(.fixed(18), spacing: 40, alignment: .center),
            ], spacing: 40) {
                ForEach(Array(icons.enumerated()), id: \.offset) { index, icon in
                    Image(icon)
                        .opacity(visibleIcons > index ? 1 : 0)
                        .animation(.easeInOut.delay(
                            delayDuration(iconIndex: index)
                        ), value: visibleIcons)
                        
                }
            }
            .frame(height: 86)
            Spacer()
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
        .task {
            try? await Task.sleep(for: .seconds(0.8))
            visibleIcons = icons.count
            let totalDuraion = delayDuration(iconIndex: icons.count - 1)
            try? await Task.sleep(for: .seconds(totalDuraion))
            coordinator.push(PreHomeRoute.onborading)
        }
    }
    
    
    func delayDuration(iconIndex: Int) -> Double {
        let animationDuration = 0.25
        let preIconsDuration: Double = icons[0 ..< iconIndex
        ].reduce(0) { total, icon in
            return total + animationDuration + 0.05 * Double(icons.count)
        }
        let curentIconDuration = Double(iconIndex) * 0.05
        return preIconsDuration + curentIconDuration
    }
}
