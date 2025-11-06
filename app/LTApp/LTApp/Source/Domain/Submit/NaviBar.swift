//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct NaviBar: View {
    let titlte: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(.back)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.leading, 24)
            
            HStack {
                Text(titlte)
                    .textStyle(size: 12, color: AppColor.color(hex: 0x423D3D), fontFamily: .poppinsRegular)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 44)
    }
}
