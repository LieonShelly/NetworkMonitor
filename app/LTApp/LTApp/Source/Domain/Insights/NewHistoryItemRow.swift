//
//  NewHistoryItemRow.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/19.
//

import SwiftUI
import UIComponent

struct NewHistoryItemRow: View {
    let history: WeeklyReportSummary

    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            DefaultOriginalIconImageView(url: history.icon.url)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 6) {
                Text(periodText)
                    .textStyle(font: .annotation, color: AppColor.greyMedium)

                Text(history.summary)
                    .textStyle(font: .title, color: AppColor.greyDark)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(content: {
            Image(.rectCover)
                .resizable()
        })
        
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
