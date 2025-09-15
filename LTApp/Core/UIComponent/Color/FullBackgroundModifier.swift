//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

public extension View {
    func defaultBackground() -> some View {
        self.modifier(FullBackgroundModifier(backgroundColor: AppColor.backgroundPage))
    }
}

public struct FullBackgroundModifier: ViewModifier {
    let backgroundColor: Color
    
    public func body(content: Content) -> some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            content
        }
    }
}
