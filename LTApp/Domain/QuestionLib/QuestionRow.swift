//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct QuestionRow: View {
    let text: String
    let isPinned: Bool
    @State private var currentOffsetX: CGFloat = .zero
    @State private var contentTrailling: CGFloat = 42
    @GestureState private var updatingOffsetX: CGFloat = .zero
    private let threshhold: CGFloat = 116
    
    var body: some View {
        row(text)
            .coordinateSpace(.named("rowNameSpace"))
            .animation(.spring(duration: 0.25), value: currentOffsetX)
            .animation(.easeInOut(duration: 0.25), value: updatingOffsetX)
    }
    
    @ViewBuilder
    func row(_ text: String) -> some View {
        ZStack(alignment: .bottomTrailing) {
            AppColor.color(hex: 0x353535)
            pinView
            contentView
            line
        }
    }
    
    var pinView: some View {
        HStack(spacing: .zero) {
            if isPinned {
                Image(.unset)
                Text("Unset")
                    .foregroundStyle(AppColor.white)
                    .textStyle(size: 14, fontFamily: .poppinsRegular)
                    .padding(.leading, 4)
            } else {
                Image(.star)
                Text("Star")
                    .foregroundStyle(AppColor.white)
                    .textStyle(size: 14, fontFamily: .poppinsRegular)
                    .padding(.leading, 4)
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding(.leading, 16)
        .padding(.trailing, 44)
    }
    
    var contentView: some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(.pinnedStar)
                .resizable()
                .frame(width: 24, height: 24)
                .padding(.leading, 10)
                .offset(y: -2)
                .opacity(isPinned ? 1 : 0)
            Text(text)
                .textStyle(size: 14, fontFamily: .poppinsRegular)
                .padding(.leading, 8)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.trailing, 42)
        .background(AppColor.backgroundPage)
        .offset(x: currentOffsetX + updatingOffsetX)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .named("rowNameSpace"))
                .updating($updatingOffsetX, body: { currentState, gestureState, transcation in
                    if currentState.velocity.width < 0 {
                        gestureState = currentState.translation.width
                    } else if currentState.velocity.width >= 0, (currentOffsetX + updatingOffsetX) != 0 {
                        gestureState = currentState.translation.width
                    }
                })
                .onEnded({ value in
                    if currentOffsetX + updatingOffsetX != 0 {
                        currentOffsetX = 0
                        contentTrailling = 42
                    } else if value.velocity.width < 0 {
                        currentOffsetX = -threshhold
                        contentTrailling = 0
                    }
                }
                        )
        )
    }
    
    var line: some View {
        Rectangle()
            .fill(AppColor.color(hex: 0xCDCDCD))
            .frame(height: 0.5)
            .padding(.horizontal, 42)
    }
}
