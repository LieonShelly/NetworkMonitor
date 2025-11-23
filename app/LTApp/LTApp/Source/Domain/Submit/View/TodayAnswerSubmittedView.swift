//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI
import UIComponent

struct TodayAnswerSubmittedView: View {
    let quesitionText: String
    let answerText: String
    @Binding var opacity: CGFloat
    @Binding var presented: Bool
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @State var imageViewOpacity: CGFloat = 0
    
    init(quesitionText: String, answerText: String, opacity: Binding<CGFloat>, presented: Binding<Bool>) {
        self.quesitionText = quesitionText
        self.answerText = answerText
        self._opacity = opacity
        self._presented = presented
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
        Text(quesitionText)
            .textStyle(size: 32, fontFamily: .vividlyRegular)
            .padding(.horizontal, 16)
            .opacity(opacity)
            .matchedGeometryEffect(id: "question", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
        
    }
    
    var answerView: some View {
        HStack {
            Text(answerText)
                .textStyle(size: 12, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .padding(.init(top: 22, leading: 18, bottom: 22, trailing: 18))
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: .init(lineWidth: 1))
                .foregroundStyle(AppColor.color(hex: 0xEBEBEB))
        )
        .frame(maxHeight: 149)
        .padding(.horizontal, 24)
        .padding(.top, 90)
        .opacity(opacity)
        .matchedGeometryEffect(id: "answer", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
    }
    
    @ViewBuilder
    var imageView: some View {
        if !homeCoordinator.dripleTransitionData.showCalendarDripple {
            Image(uiImage: LocalIconLib.fallLeave)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 147)
                .padding(.top, 58)
                .opacity(imageViewOpacity)
                .matchedGeometryEffect(id: "dripple", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
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
}
