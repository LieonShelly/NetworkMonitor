//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent
import AudioToolbox


struct SplashView: View {
    enum CurrentPage {
        case first
        case second
        case third
    }
    @EnvironmentObject var coordinator: PreHomeCoordinator
    @State var currentPage: CurrentPage = .second
    @StateObject var viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
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
            font: AppFont.heading.uifont,
            width: 188) {
                currentPage = .second
            }
    }
    
    
    var secondScreen: some View {
        AnimatedMultilineText(text:  viewModel.sentence?.page2st ?? "grow your reflections into insights with guided questions", font: AppFont.heading.uifont, width: 307) {
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
    @State var visibleIcons: Set<Int> = []
    @State var showText: Bool = false
    private let alwaysVisibleIndices: Set<Int> = []
    
    var thirdSceen: some View {
        VStack(spacing: .zero) {
            Text(viewModel.sentence?.page3st ?? "each answer will generate a unique icon of your own ")
                .multilineTextAlignment(.center)
                .lineLimit(10)
                .frame(width: 335)
                .font(AppFont.heading.font)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.bottom, 172)
                .padding(.top, 114)
                .opacity(showText ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: showText)
            
            LazyVGrid(columns: [
                .init(.fixed(18), spacing: 40, alignment: .center),
                .init(.fixed(18), spacing: 40, alignment: .center),
                .init(.fixed(18), spacing: 40, alignment: .center),
                .init(.fixed(18), spacing: 40, alignment: .center),
            ], spacing: 40) {
                ForEach(Array(icons.enumerated()), id: \.offset) { index, icon in
                    let isVisible = alwaysVisibleIndices.contains(index) || visibleIcons.contains(index)
                    Image(icon)
                        .opacity(isVisible ? 1 : 0)
                        .scaleEffect(isVisible ? 1 : 0.3)
                        .animation(.easeOut(duration: 0.35), value: isVisible)
                }
            }
            .frame(height: 86)
            Spacer()
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
        .task {
            try? await Task.sleep(for: .seconds(0.8))
            await revealIconsRandomly()
            withAnimation(.easeOut(duration: 0.5)) {
                showText = true
            }
            try? await Task.sleep(for: .seconds(1.5))
            coordinator.push(PreHomeRoute.onborading)
        }
    }
    
    private func revealIconsRandomly() async {
        var remaining = Array(0..<icons.count).filter { !alwaysVisibleIndices.contains($0) }.shuffled()
        while !remaining.isEmpty {
            let batchSize = min(Bool.random() ? 2 : 1, remaining.count)
            let batch = remaining.prefix(batchSize)
            remaining.removeFirst(batchSize)
            withAnimation {
                for i in batch {
                    visibleIcons.insert(i)
                }
            }
            AudioServicesPlaySystemSound(1519)
            try? await Task.sleep(for: .seconds(0.3))
        }
    }
}
