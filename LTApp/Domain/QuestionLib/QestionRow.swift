//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct QestionRow: View {
    let text: String
    
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
        ZStack(alignment: .trailing) {
            AppColor.color(hex: 0x353535)
            HStack(spacing: .zero) {
                VStack(spacing: .zero) {
                    HStack {
                        Text(text)
                            .textStyle(size: 14, fontFamily: .poppinsRegular)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    
                    Rectangle()
                        .fill(AppColor.color(hex: 0xCDCDCD))
                        .frame(height: 0.5)
                }
                .padding(.leading, 42)
                .padding(.trailing, contentTrailling)
                .background(AppColor.backgroundPage)
            }
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
                        if currentOffsetX != 0 {
                            currentOffsetX = 0
                            contentTrailling = 42
                        } else if value.velocity.width < 0 {
                            currentOffsetX = -threshhold
                            contentTrailling = 0
                        }
                    }
                            )
            )
            HStack(spacing: .zero) {
                Image(.star)
                
                Text("Star")
                    .foregroundStyle(AppColor.white)
                    .textStyle(size: 14, fontFamily: .poppinsRegular)
                    .padding(.leading, 4)
                
            }
            .padding(.leading, 16)
            .padding(.trailing, 44)
        }
    }
}
