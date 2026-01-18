//
//  InnerPageRoutingModifier.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/5.
//

import SwiftUI
import UIComponent

struct InnerPageRoutingModifier: ViewModifier {
    @Binding var subPageRoute: InnerPageRouteState
    @State var subPagePrensented: Bool = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            switch subPageRoute {
            case .todayAnswer(let todayAnswerViewModel):
                TodayAnswerView(viewModel: todayAnswerViewModel, presented: $subPagePrensented)
                    .transition(
                        .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            case .addSingleAnswer(let todayAnswerViewModel):
                TodayAnswerView(viewModel: todayAnswerViewModel, presented: $subPagePrensented)
                    .transition(
                        .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            case .answerDetail(let todayAnswerSubmittedViewModel):
                AnswerDetailView(viewModel: todayAnswerSubmittedViewModel, dismissed: {
                    print("onDisappear")
                    subPageRoute = .none
                })
                .transition(.opacity)
            case .none:
                EmptyView()
            }
        }
        .onChange(of: subPagePrensented) { oldValue, newValue in
            subPageRoute = .none
        }
    }
}


extension View {
    
    func innerPageRoute(_ state: Binding<InnerPageRouteState>) -> some View {
        modifier(InnerPageRoutingModifier(subPageRoute: state))
    }
}
