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
    @State var imageCoverScale: CGFloat = 1
    @State var imageCoverEnpoint: CGFloat = 0
    @State var imageOpacity: CGFloat = 0
    
    init(viewModel: TodayAnswerSubmittedViewModel, opacity: Binding<CGFloat> = .constant(1), dismissed: @escaping () -> Void) {
        self._opacity = opacity
        self.dismissed = dismissed
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            questionView
            if let url = viewModel.answer.icon?.url, !url.isEmpty {
                imageAnswerView
            } else {
                loadingAnswerView
                    .onAppear {
                        viewModel.queryCurrenntIconStatus()
                    }
            }
            Spacer()
            closeBtn
        }
        .animation(.easeInOut, value: opacity)
    }
    
    @ViewBuilder var imageAnswerView: some View {
        ZStack(alignment: .top) {
            VStack(spacing: .zero) {
                imageView
                answerView
            }
            .opacity(imageOpacity)
            
            imageCover
                .onAppear {
                    withAnimation(.easeInOut.delay(0.5)) {
                        imageOpacity = 1
                    }
                }
        }
    }
    
    @ViewBuilder var loadingAnswerView: some View {
        loadingView
        answerView
    }
    
    var questionView: some View {
        Text(viewModel.question.title)
            .textStyle(font: .heading)
            .padding(.horizontal, 24)
            .opacity(opacity)
        
    }
    
   @ViewBuilder var answerView: some View {
        HStack {
            Text(viewModel.answer.content)
                .textStyle(font: .body, color: AppColor.greyDark)
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
    }
    
    @ViewBuilder
    var imageView: some View {
        if showBtn, let icon = viewModel.answer.icon, let url = icon.url, !url.isEmpty {
            OriginalIconView(url: url) { } onSuccess: {
                Task.detached {
                    await viewModel.markIconAsRead(icon)
                }
                withAnimation(.easeInOut(duration: 4)) {
                    imageCoverScale = 0
                }
                withAnimation(.easeInOut(duration: 0.1)) {
                    imageCoverEnpoint = 0.2
                }
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 50)
            .transition(.opacity)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + 0.25, execute: {
                    dismissed()
                })
                
            } label: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.color(hex: 0xEBEBEB, alpha: 0.92))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(.xmark)
                            .renderingMode(.template)
                            .foregroundStyle(AppColor.color(hex: 0x000000, alpha: 0.85))
                    }
            }
            .padding(.top, 20)
            .padding(.bottom, 45)
            .transition(.opacity)
        }
      
    }
    
    @ViewBuilder var loadingView: some View {
        if showBtn {
            VStack(spacing: .zero) {
                LoadingView()
                    .frame(width: 290, height: 200)
                    .transition(.opacity)
                
                Text("Weaving your moments...")
                    .textStyle(font: .heading)
                    .padding(.vertical, 36)
                    .transition(.opacity)
            }
            .padding(.top, 42)
            .transition(.opacity)
        }
    
    }
    
   @ViewBuilder var imageCover: some View {
        if showBtn {
            LinearGradient(gradient: .init(colors: [
                AppColor.color(hex: 0xFFFDF8).opacity(0),
                AppColor.color(hex: 0xFFFDF8),
            ]), startPoint: .init(x: 0.5, y: 0), endPoint: .init(x: 0.5, y: 0.1))
            .scaleEffect(.init(width: 1, height: imageCoverScale), anchor: .init(x: 0.5, y: 1))
            .transition(.opacity)
        }
        
    }
}
