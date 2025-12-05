//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI
import UIComponent

struct TodayAnswerSubmittedView: View {
    @StateObject var viewModel: TodayAnswerSubmittedViewModel
    @Binding var opacity: CGFloat
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    let dismissed: () -> Void
    @State var showBtn: Bool = true
    
    init(viewModel: TodayAnswerSubmittedViewModel, opacity: Binding<CGFloat> = .constant(1), dismissed: @escaping () -> Void) {
        self._opacity = opacity
        self.dismissed = dismissed
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            questionView
            imageView
            answerView
            Spacer()
            closeBtn
        }
        .animation(.easeInOut, value: opacity)
        .task {
            homeCoordinator.dripleTransitionData?.showCalendarDripple = false
        }
    }
    
    var questionView: some View {
        Text(viewModel.question.title)
            .textStyle(size: 32, fontFamily: .vividlyRegular)
            .padding(.horizontal, 16)
            .opacity(opacity)
            .matchedGeometryEffect(id: "question", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
        
    }
    
   @ViewBuilder var answerView: some View {
        HStack {
            Text(viewModel.answer.content)
                .textStyle(size: 12, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .padding(.init(top: 22, leading: 18, bottom: 22, trailing: 18))
            Spacer()
        }
        .clipped()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: .init(lineWidth: 1))
                .foregroundStyle(AppColor.color(hex: 0xEBEBEB))
        )
        .padding(.horizontal, 24)
        .opacity(opacity)
        .matchedGeometryEffect(id: "answer", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
    }
    
    @ViewBuilder
    var imageView: some View {
        if !homeCoordinator.dripleTransitionData.showCalendarDripple {
            if let url = viewModel.answer.icon?.url, !url.isEmpty {
                OriginalIconView(url: url) {
                    loadingView
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 50)
                .matchedGeometryEffect(id: "dripple", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
            } else {
                loadingView
                    .padding(.top, 42)
                    .matchedGeometryEffect(id: "dripple", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
            }
        }
    }
    
   @ViewBuilder var closeBtn: some View {
        if showBtn {
            Button {
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 0
                }
                withAnimation(.easeIn(duration: 0.5)) {
                    showBtn = false
                }
                withAnimation(.easeIn(duration: 0.5)) {
                    homeCoordinator.dripleTransitionData?.showCalendarDripple = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + 0.25, execute: {
                    dismissed()
                })
                
            } label: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.color(hex: 0xD9D9D9))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(.xmark)
                    }
            }
            .padding(.top, 20)
            .padding(.bottom, 45)
            .transition(.opacity)
        }
      
    }
    
    var loadingView: some View {
        VStack(spacing: .zero) {
            LoadingView()
                .frame(width: 290, height: 200)
            
            Text("Weaving your thoughts...")
                .textStyle(size: 24, fontFamily: .feltTipSeniorRegular)
                .padding(.vertical, 36)
        }
    }
}
