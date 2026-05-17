//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct UserRow: View {
    let item: UserRowItem
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(spacing: .zero) {
                item.icon
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Text(item.title)
                    .textStyle(size: 28)
                    .padding(.leading, 8)
                
                Spacer()
                Image(.more)
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            Text(item.subTitle)
                .textStyle(size: 14, color: AppColor.color(hex: 0x6F6F6F), fontFamily: .poppinsRegular)
                .padding(.leading, 32 + 11)
        }
        .padding(.horizontal, 34)
    }
}
