//
//  ReportHistoryRow.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/22.
//

import SwiftUI
import UIComponent

struct ReportHistoryRow: View {
    let history: WeeklyReportSummary
    
    var body: some View {
        HStack(spacing: .zero) {
            DefaultOriginalIconImageView(url: history.icon.url)
            .frame(width: 64, height: 64)
            
            VStack(alignment: .leading, spacing: .zero) {
                Text("\(history.periodStart.yyyymmdd) - \(history.periodEnd.yyyymmdd)")
                    .textStyle(size: 11, fontFamily: .ibmPlexMonoRegular)
                
                Text(history.summary)
                    .lineLimit(3)
                    .textStyle(size: 13, fontFamily: .poppinsRegular)
                    .padding(.top, 4)
                
                
            }
            .padding(.leading, 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .frame(height: 112)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.color(hex: 0x888888), lineWidth: 1)
        }
    }
}
