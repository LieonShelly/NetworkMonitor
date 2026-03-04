//
//  InsightsView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/10/30.
//

import SwiftUI
import UIComponent

struct InsightsView: View {
    @State var viewModel: InsightsViewModel
    
    init(viewModel: InsightsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            titleView
            contentView
        }
        .onFirstAppear {
            Task.detached {
                try? await viewModel.fetchData()
            }
        }
    }
    
    var titleView: some View {
        HStack(spacing: .zero) {
            Text("AI Insights")
                .textStyle(size: 33)
        }
        .padding(.vertical, 12)
    }
    
    var contentView: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                summaryView
            }
        }
    }
    
    @ViewBuilder
    var summaryView: some View {
        if let report = viewModel.weeklyReport {
            VStack(spacing: .zero) {
                iconListView(report: report)
                line(axis: .horizontal)
                summaryContentView(report: report)
            }
            .overlay(content: {
                VStack {
                    line(axis: .horizontal)
                    Spacer()
                    line(axis: .horizontal)
                }
            })
            .overlay(content: {
                HStack {
                    line(axis: .vertical)
                    Spacer()
                    line(axis: .vertical)
                }
            })
            .padding(.horizontal, 32)
        }
       
    }
    
    @ViewBuilder func iconListView(report: WeeklyReport) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("\(report.periodStart.yyyymmdd) - \(report.periodEnd.yyyymmdd)")
                .textStyle(size: 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                .padding(.leading, 20)
                .padding(.top, 16)
                .padding(.bottom, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(report.icons, id: \.iconId) { iconData in
                        IconView(iconData: iconData)
                    }
                }
            }
            .frame(height: 32)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
        }
    }
    
    @ViewBuilder func summaryContentView(report: WeeklyReport) -> some View {
        
        VStack(alignment: .leading, spacing: .zero) {
            Text("// The Summary")
                .textStyle(size: 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                .padding(.leading, 20)
                .padding(.top, 16)
                .padding(.bottom, 14)
            
            Text(report.reportJson.summary)
                .textStyle(size: 13, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
    }
    
    func line(axis: Axis) -> some View {
        WavyLine(segmentCount: 100, seed: 400, axis: axis)
            .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round))
            .foregroundColor(AppColor.color(hex: 0x000000))
            .if(axis == .horizontal, transform: {
                $0.frame(height: 2)
            })
            .if(axis == .vertical, transform: {
                $0.frame(width: 2)
            })
          

    }
}
