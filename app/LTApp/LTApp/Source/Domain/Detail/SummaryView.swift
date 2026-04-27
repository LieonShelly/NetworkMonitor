//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct SummaryView: View {
    let summary: ReflectionSummary
    @State var show: Bool = false
    @Binding var isPresented: Bool
    @State var dragOffsetY: CGFloat = 0
    @State private var currentOffsetY: CGFloat = .zero
    @State private var lastOffsetY: CGFloat = .zero
    @GestureState private var updatingOffsetY: CGFloat = .zero
    
    init(summary: ReflectionSummary, isPresented: Binding<Bool>) {
        self.summary = summary
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if show {
                AppColor.color(hex: 0x000000).opacity(0.25)
                    .transition(.opacity)
                    .onTapGesture {
                        show.toggle()
                    }
                
                Rectangle()
                    .fill(AppColor.backgroundPage)
                    .frame(height: max(0, -(currentOffsetY + updatingOffsetY)))
                
                  VStack(spacing: .zero) {
                      topLine
                      text
                          .padding(.horizontal, 32)
                          .padding(.top, 32)
                          .padding(.bottom, 54)
                      closeBtn
                  }
                  .background(
                      RoundedRectangleWithCorners(radius: 20, corners: [.topLeft, .topRight])
                          .fill(AppColor.backgroundPage)
                  )
                  .offset(y: currentOffsetY + updatingOffsetY)
                  .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                  .zIndex(100)
                  .gesture(DragGesture()
                    .updating($updatingOffsetY, body: { currentState, gestureState, transaction in
                        gestureState = currentState.translation.height
                        lastOffsetY = currentOffsetY + updatingOffsetY
                    })
                        .onEnded({ value in
                            currentOffsetY = lastOffsetY
                            if currentOffsetY < 0 {
                                withAnimation(.easeInOut) {
                                    currentOffsetY = .zero
                                }
                            } else if currentOffsetY > 0 {
                                show.toggle()
                            }
                        })
                  )
                  .onDisappear {
                      isPresented.toggle()
                  }
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut, value: show)
        .task {
            show.toggle()
        }
      
    }
    
    var topLine: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AppColor.color(hex: 0xD9D9D9))
            .frame(width: 60, height: 6)
            .padding(.top, 12)
    }
    
    var text: some View {
        HStack {
            Text("Since \(summary.firstAnswerAt.formatDateToEnglishStyle()), you’ve captured this spark")
                .foregroundStyle(AppColor.greyMedium)
                .font(AppFont.body.font)
            
            + Text("\(summary.totalAnswers) times \n\n")
                .foregroundStyle(AppColor.greyMedium)
                .font(AppFont.bodyBold.font)
            
           +  Text("Revisiting the same moments together over time reveals the quiet rhythms of your days. It’s a gentle reminder of what brings you warmth, even when it rains. Take a breath, and let the thread grow at your own pace.")
                .foregroundStyle(AppColor.greyMedium)
                .font(AppFont.body.font)
              
            Spacer()
        }
    }
    
    var closeBtn: some View {
        Button {
            show.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xEBEBEB, alpha: 0.92))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(.xmark)
                }
        }
        .padding(.bottom, 45)
    }
}



