//
//  ReportedView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/22.
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
                Text("\(report.periodStart.yyyymmdd) - \(report.periodEnd.yyyymmdd)")
                    .textStyle(size: 16, color: AppColor.color(hex: 0x423D3D), fontFamily: .poppinsRegular)
            }, backAction:  {
                withAnimation {
                    router.pop()
                }
            })
        }
    }
}
