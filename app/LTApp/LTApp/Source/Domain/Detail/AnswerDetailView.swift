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
    @Binding var presented: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColor.backgroundPage
            NaviBar(titlte: viewModel.title, hideBackBtn: true) {
            }
            .zIndex(1)
            
            TodayAnswerSubmittedView(
                viewModel: viewModel,
                opacity: $opacity,
                presented: $presented
            )
            .padding(.top, 44)
            .contentShape(.rect)
            .padding(.top, 20)

        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}
