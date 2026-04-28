//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import Foundation
import Combine

struct AppTabbar: View {
    @ObservedObject var viewModel: AppTabbarViewModel
    enum Constants {
        static let height: CGFloat = 40
        static let vP: CGFloat = 16
        
        static let tabbarTotalH = height + vP * 2
    }
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(0 ..< viewModel.items.count, id: \.self) { index in
                let item = viewModel.items[index]
                AppTabbarView(
                    item: item,
                    action: {
                        viewModel.didTapTabrItem(item)
                    }
                )
                .frame(width: 40, height: Constants.height)
            }
        }
        .padding(.horizontal, 42)
        .padding(.vertical, Constants.vP)
        .background(
            background
        )
    }
    
    var addBtn: some View {
        Button {
        } label: {
            Image(.addAnswer)
                .resizable()
        }
        .frame(width: 60, height: 60)
        .offset(y: -15)
    }
    
    var background: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(Color.black)
            .frame(height: 64)
    }
}
