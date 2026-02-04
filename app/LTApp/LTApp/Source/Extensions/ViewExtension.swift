//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct PureIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

extension View {
    func defaultNavigationBar(_ title: String, backBtnAction: (() -> Void)? = nil) -> some View {
        self
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HStack {
                        Button {
                            backBtnAction?()
                        } label: {
                            Image(.back)
                        }
                        .buttonStyle(PureIconButtonStyle())
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .textStyle(size: 36)
                }
            }
    }
}


private struct PositionPreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    func currentRect(_ rect: Binding<CGRect>, coordinateSpace: CoordinateSpace = .global) -> some View {
        overlay(content: {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: PositionPreferenceKey.self, value: geometry.frame(in: .global))
            }
        })
        .onPreferenceChange(PositionPreferenceKey.self) { value in
            rect.wrappedValue = value
        }
    }
}
