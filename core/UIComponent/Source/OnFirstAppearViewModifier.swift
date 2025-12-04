//
//  OnFirstAppearViewModifier.swift
//  UIComponent
//
//  Created by Renjun Li on 2025/12/4.
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
