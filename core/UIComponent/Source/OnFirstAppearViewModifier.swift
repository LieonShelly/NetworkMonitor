//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
struct OnFirstAppearViewModifier: ViewModifier {
    @State private var viewDidAppear = false

    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if !viewDidAppear {
                viewDidAppear = true

                action?()
            }
        }
    }
}

@MainActor
public extension View {
    func onFirstAppear(perform action: (@MainActor () -> Void)? = nil) -> some View {
        modifier(
            OnFirstAppearViewModifier(perform: action)
        )
    }
}
