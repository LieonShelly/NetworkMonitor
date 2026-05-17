//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct NewUserRow: View {
    let icon: Image
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .textStyle(font: .title, color: AppColor.black)
                
                Text(subtitle)
                    .textStyle(font: .caption, color: AppColor.greyMedium)
                    .lineLimit(1)
            }
            .padding(.leading, 14)
            
            Spacer()
            
            Image(.more)
                .resizable()
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, 24)
        .contentShape(.rect)
    }
}
