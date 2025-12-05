//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI
import UIComponent

struct TodayAnswerSubmittedView: View {
    @StateObject var viewModel: TodayAnswerSubmittedViewModel
    @Binding var opacity: CGFloat
    @Binding var presented: Bool
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @State var imageViewOpacity: CGFloat = 0
    
    init(viewModel: TodayAnswerSubmittedViewModel, opacity: Binding<CGFloat> = .constant(1), presented: Binding<Bool>) {
        self._opacity = opacity
        self._presented = presented
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
            imageViewOpacity = 1
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
                .matchedGeometryEffect(id: "dripple", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
            } else {
                loadingView
                    .padding(.top, 42)
                    .matchedGeometryEffect(id: "dripple", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
            }
        }
    }
    
    var closeBtn: some View {
        Button {
            withAnimation(.easeIn(duration: 0.5), completionCriteria: .logicallyComplete) {
                opacity = 0
                homeCoordinator.dripleTransitionData?.showCalendarDripple = true
            } completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    presented.toggle()
                })
            }
            
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xD9D9D9))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(.xmark)
                }
        }
        .padding(.bottom, 45)
        .opacity(opacity)
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
