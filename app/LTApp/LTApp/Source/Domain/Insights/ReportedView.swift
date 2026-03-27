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
    }
    
    @ViewBuilder var topBar: some View {
        if let report = viewModel.weeklyReport {
            HStack {
                Image(.back)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        viewModel.state = .history
                    }
                Spacer()
                Text("\(report.periodStart.yyyymmdd) - \(report.periodEnd.yyyymmdd)")
                    .textStyle(size: 16, color: AppColor.color(hex: 0x423D3D), fontFamily: .poppinsRegular)
            }
            .frame(height: 32)
            .padding(.horizontal, 24)
            .padding(.bottom, 6)
        }
    }
}
