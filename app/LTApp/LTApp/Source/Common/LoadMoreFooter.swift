//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct LoadMoreFooter: View {
    let state: LoadMoreState
    let onRetry: () async -> Void

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case .loading:
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical, 16)
        case .noMore:
            HStack {
                Spacer()
                Text("No more data")
                    .textStyle(size: 18, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
                Spacer()
            }
            .padding(.vertical, 16)
        case .error(let message):
            VStack(spacing: 8) {
                Text(message)
                    .multilineTextAlignment(.center)
                    .textStyle(size: 18, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
                Button {
                    Task { await onRetry() }
                } label: {
                    Text("Retry")
                        .textStyle(size: 18, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
}
