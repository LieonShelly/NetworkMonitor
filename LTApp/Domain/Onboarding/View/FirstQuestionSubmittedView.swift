//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct FirstQuestionSubmittedData {
    let category: String
    let question: String
    let answerText: String
    let createAt: Date
}

struct FirstQuestionSubmittedView: View {
    let data: FirstQuestionSubmittedData
    @State var dismiss: Bool = false
    @EnvironmentObject var coordinaor: AppCoordinator
    @EnvironmentObject var homeCoordinaor: HomeCoordinator
    @State var showFramesAniamtion: Bool = false
    
    init(data: FirstQuestionSubmittedData) {
        self.data = data
    }

    var body: some View {
        submittedForm
            .defaultBackground(opacity: dismiss ? 0 : 1)
            .animation(.easeInOut(duration: 0.5), value: dismiss)
            .animation(.easeInOut(duration: 0.5), value: showFramesAniamtion)
            .task {
                showFramesAniamtion = true
            }
    }
    
    var submittedForm: some View {
        VStack(spacing: .zero) {
            topicTitleSubmittedView
            
            if let lastFrame = FramesAnimationData.dripple.lastFrame {
                HStack {
                    if  let dripleTransitionData = homeCoordinaor.dripleTransitionData {
                        if showFramesAniamtion, !dripleTransitionData.showDrippleClose {
                            ImageFramesAnimationView(aniamationData: .dripple)
                                .transition(.opacity)
                        } else if !dripleTransitionData.showCalendarDripple {
                            Circle()
                                .fill(Color.clear)
                                .overlay(content: {
                                    Image(uiImage: lastFrame)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                })
                                .transition(.opacity)
                                .matchedGeometryEffect(id: "dripple", in: dripleTransitionData.drippleAnimationSpace)
                        }
                    }
                }
                    .frame(width: FramesAnimationData.dripple.frameSize.width,
                           height: FramesAnimationData.dripple.frameSize.height)
                    .padding(.top, 100)
            }
            
            HStack {
                Text(data.question)
                    .textStyle(size: 24)
                    .lineLimit(10)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 59)
            .opacity(dismiss ? 0 : 1)
            
            HStack {
                Text(data.answerText)
                    .textStyle(size: 12, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                    .padding(.init(top: 22, leading: 18, bottom: 22, trailing: 18))
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: .init(lineWidth: 1))
                    .foregroundStyle(AppColor.color(hex: 0xEBEBEB))
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .opacity(dismiss ? 0 : 1)
            
            HStack {
                Text(data.createAt.formatDateToEnglishStyle())
                    .textStyle(size: 10, color: AppColor.color(hex: 0x9e9e9e), fontFamily: .sfProRegular)
                Spacer()
            }
            .padding(.horizontal, 24)
            .transition(.opacity)
            .opacity(dismiss ? 0 : 1)
            Spacer()
            
            closeBtn
            
        }
    }
    
    var topicTitleSubmittedView: some View {
        HStack(spacing: 6) {
            Text(data.category)
                .textStyle(size: 14, color: .white, fontFamily: .sfProBold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColor.textPrimary)
        .cornerRadius(16, corners: .allCorners)
        .padding(.top, 16)
        .opacity(dismiss ? 0 : 1)
    }
    
    var closeBtn: some View {
        Button {
            Task {
                dismiss = true
                withAnimation(.easeIn(duration: 0.5)) {
                    homeCoordinaor.dripleTransitionData?.showCalendarDripple = true
                }
            }
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xEBEBEBEB).opacity(0.92))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(.back)
                }
        }
        .padding(.bottom, 42)
        .transition(.opacity)
        .opacity(dismiss ? 0 : 1)
    }
}
