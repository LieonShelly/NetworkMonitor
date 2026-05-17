//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

public extension View {
    func defaultBackground(opacity: CGFloat = 1.0) -> some View {
        self.modifier(FullBackgroundModifier(backgroundColor: AppColor.backgroundPage.opacity(opacity)))
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
