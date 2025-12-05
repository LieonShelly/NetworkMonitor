//
//  AnswerDetailView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/2.
//


import SwiftUI
import UIComponent
import Kingfisher

struct AnswerDetailView: View {
    @ObservedObject var viewModel: TodayAnswerSubmittedViewModel
    @State var opacity: CGFloat = 1
    let dismissed: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColor.backgroundPage.opacity(opacity).ignoresSafeArea()
            NaviBar(titlte: viewModel.title, hideBackBtn: true) {
            }
            .opacity(opacity)
            .zIndex(1)
            
            TodayAnswerSubmittedView(
                viewModel: viewModel,
                opacity: $opacity,
                dismissed: dismissed
            )
            .frame(maxHeight: .infinity)
            .padding(.top, 44)
            .contentShape(.rect)
            .padding(.top, 20)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .allowsHitTesting(true)
        .onDisappear {
            print("AnswerDetailView-onDisappear")
        }
    }
}
