//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct UnreadReportHistoryRow: View {
    let history: WeeklyReportSummary
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 2) {
                Text("tap to reveal".uppercased())
                    .textStyle(size: 20, fontFamily: .poppinsRegular)
                
                Text("\(history.periodStart.yyyymmdd) - \(history.periodEnd.yyyymmdd)")
                    .textStyle(size: 11, fontFamily: .ibmPlexMonoRegular)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColor.color(hex: 0x888888), lineWidth: 1)
            }
            
            Circle()
                .fill(AppColor.color(hex: 0x000000))
                .frame(width: 21, height: 21)
                .offset(x: 10, y: -10)
        }
     
    }
}
