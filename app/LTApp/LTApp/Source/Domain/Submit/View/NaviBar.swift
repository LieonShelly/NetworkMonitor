//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct NaviBar: View {
    let titlte: String
    let hideBackBtn: Bool
    let popback: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(.back)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.leading, 24)
                .opacity(hideBackBtn ? 0 : 1)
                .onTapGesture {
                    popback?()
                }
            
            HStack {
                Text(titlte)
                    .textStyle(font: .section, color: AppColor.greyMedium)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 44)
    }
}
