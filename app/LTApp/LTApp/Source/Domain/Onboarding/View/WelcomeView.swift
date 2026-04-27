//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct WelcomeView: View {
    enum CurrentPage {
        case first
        case second
    }
    
    @State var currentPage: CurrentPage = .first
    @State var showPage: Bool = false
    @State var showSecondPageText: Bool = false
    @State var showGoBtn: Bool = false
    @EnvironmentObject var coordinator: PreHomeCoordinator
    @StateObject var viewModel: WelcomeViewModel
    
    init(viewModel: WelcomeViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if showPage {
                VStack {
                    switch currentPage {
                    case .first:
                        firstTextView
                    case .second:
                        secondTextView
                    }
                }
                .defaultBackground()
                .toolbarVisibility(.hidden, for: .navigationBar)
                .transition(.opacity)
            }
        }
        .task {
            await viewModel.fetchData()
            try? await Task.sleep(for: .seconds(0.25))
            withAnimation(.easeInOut) {
                showPage = true
            }
        }
       
    }
    
    var firstTextView: some View {
        AnimatedMultilineText(
            text: "welcome",
            font: AppFont.heading.uifont,
            width: 305,
            animationCompleted: {
                withAnimation(.easeInOut) {
                    currentPage = .second
                }
                Task {
                    try? await Task.sleep(for: .seconds(0.25))
                    showSecondPageText = true
                }
            }
        )
            .frame(width: 305)
            .transition(.asymmetric(insertion: .identity, removal: .move(edge: .leading)).combined(with: .opacity))
    }
    
    var secondTextView: some View {
        VStack {
            Spacer()
            if showSecondPageText {
                AnimatedMultilineText(
                    text: viewModel.sentence?.page5st ?? "the canvas is yours, leave your first thought here to begin",
                    font: AppFont.heading.uifont,
                    width: 305,
                    animationCompleted: {
                        showGoBtn = true
                    }
                )
                    .frame(width: 305)
            }
                
            Spacer()
            DefaultAppButton(title: "let's go") {
                coordinator.push(PreHomeRoute.firstQuestion(viewModel.category))
            }
            .padding(.horizontal, 24)
            .opacity(showGoBtn ? 1 : 0)
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
       
    }
}
