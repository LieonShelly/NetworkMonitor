//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import Foundation
import Combine

struct AppTabbar: View {
    @ObservedObject var viewModel: AppTabbarViewModel
    
    var body: some View {
        HStack(spacing: .zero) {
            ForEach(0 ..< viewModel.items.count, id: \.self) { index in
                let item = viewModel.items[index]
                AppTabbarView(
                    icon: item.icon,
                    normalColor: item.normalColor,
                    selectedColor: item.selectedColor,
                    selectedOpacity: item.selectedOpacity,
                    action: {
                        viewModel.didTapTabrItem(item)
                    }
                )
                .frame(width: 40, height: 40)
                if index != viewModel.items.count - 1 {
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 64)
        .background(
            background
        )
        .overlay(alignment: .top) {
            addBtn
        }
    }
    
    var addBtn: some View {
        Button {
        } label: {
            Image(.add)
                .resizable()
        }
        .frame(width: 60, height: 60)
        .offset(y: -15)
    }
    
    var background: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .frame(height: 64)
    }
}

#Preview {
    AppTabbarExampleView()
}
