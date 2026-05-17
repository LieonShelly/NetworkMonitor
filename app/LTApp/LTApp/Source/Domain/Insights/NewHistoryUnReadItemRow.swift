//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct NewHistoryUnReadItemRow: View {
    let history: WeeklyReportSummary
    
    
    var  body: some View {
        
        ZStack(alignment: .top) {
            
            Text(periodText)
                .textStyle(size: 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                .padding(.top, 8)

            Image(.letter)
                .resizable()
                .frame(height: 88)
                .frame(maxWidth: .infinity)
                .overlay {
                    ZStack {
                        Image(.ellipse142)
                            .resizable()
                            .frame(width: 32, height: 32)
                        Image(.qMark)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 30)
                    }
                    .offset(x: 30, y: 0)
                }
        }
    }
    
    
    private var periodText: String {
        let calendar = AppCalendar.current
        let startDay = calendar.component(.day, from: history.periodStart)
        let endDay = calendar.component(.day, from: history.periodEnd)
        let endMonth = history.periodEnd.monthDesc(isShort: true).uppercased()

        if calendar.isDate(history.periodStart, equalTo: history.periodEnd, toGranularity: .month) {
            return "\(startDay) - \(endDay) \(endMonth)"
        } else {
            let startMonth = history.periodStart.monthDesc(isShort: true).uppercased()
            return "\(startDay) \(startMonth) - \(endDay) \(endMonth)"
        }
    }
}
