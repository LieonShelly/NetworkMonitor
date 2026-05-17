//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
           Text(viewModel.title)
                .textStyle(font: .section, color: AppColor.greyMedium)
                .frame(height: 72)
            .opacity(opacity)
            .zIndex(1)
            
            TodayAnswerSubmittedView(
                viewModel: viewModel,
                opacity: $opacity,
                dismissed: dismissed
            )
            .frame(maxHeight: .infinity)
            .padding(.top, 72)
            .contentShape(.rect)
            .padding(.top, 16)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .allowsHitTesting(true)
        .onDisappear {
            print("AnswerDetailView-onDisappear")
        }
    }
}
