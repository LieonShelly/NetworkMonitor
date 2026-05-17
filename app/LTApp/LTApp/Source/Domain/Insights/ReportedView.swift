//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct ReportedView: View {
    @ObservedObject var viewModel: InsightsViewModel
    @EnvironmentObject var router: InsightsRouter
    @EnvironmentObject var tabbarVisibility: TabbarVisibility
    
    var body: some View {
        VStack(spacing: .zero) {
            topBar
            ScrollView {
                LazyVStack(spacing: .zero) {
                    PaperView(viewModel: viewModel)
                }
                .padding(.bottom, 80)
            }
        }
        .defaultBackground()
        .onAppear {
            tabbarVisibility.isVisible = false
        }
        .onDisappear {
            tabbarVisibility.isVisible = true
        }
    }
    
    @ViewBuilder var topBar: some View {
        if let report = viewModel.weeklyReport {
            FixedHeader(title: "", trailing: {
                Text(periodText(report))
                    .textStyle(size: 16, color: AppColor.black, fontFamily: .littleThing)
            }, backAction:  {
                withAnimation {
                    router.pop()
                }
            })
        }
    }
    
    private func periodText(_ report: WeeklyReport) -> String {
        let calendar = AppCalendar.current
        let startDay = calendar.component(.day, from: report.periodStart)
        let endDay = calendar.component(.day, from: report.periodEnd)
        let endMonth = report.periodEnd.monthDesc(isShort: true).uppercased()

        if calendar.isDate(report.periodStart, equalTo: report.periodEnd, toGranularity: .month) {
            return "\(startDay) - \(endDay) \(endMonth)"
        } else {
            let startMonth = report.periodStart.monthDesc(isShort: true).uppercased()
            return "\(startDay) \(startMonth) - \(endDay) \(endMonth)"
        }
    }
}
