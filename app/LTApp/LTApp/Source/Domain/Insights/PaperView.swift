//
//  PaperView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/26.
//

import SwiftUI
import UIComponent

struct PaperView: View {
    @ObservedObject var viewModel: InsightsViewModel
    var isSmall: Bool = false
    
    var body: some View {
        VStack(spacing: .zero) {
            summaryView
            momentView
            overView
        }
        .defaultBackground()
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
            .padding(.horizontal, isSmall ? 14: 32)
        }
        
    }
    
    @ViewBuilder func iconListView(report: WeeklyReport) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("\(report.periodStart.yyyymmdd) - \(report.periodEnd.yyyymmdd)")
                .textStyle(size: isSmall ? 9 : 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                .padding(.leading, isSmall ? 14 :20)
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
            .padding(.horizontal, isSmall ? 10 : 20)
            .padding(.bottom, 12)
            
        }
    }
    
    @ViewBuilder func summaryContentView(report: WeeklyReport) -> some View {
        
        VStack(alignment: .leading, spacing: .zero) {
            Text("// The Summary")
                .textStyle(size: isSmall ? 9 : 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                .padding(.leading, isSmall ? 10 : 20)
                .padding(.top, isSmall ? 8: 16)
                .padding(.bottom, isSmall ? 7: 14)
            
            Text(report.reportJson.summary)
                .textStyle(size: isSmall ? 9: 13, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, isSmall ? 10: 20)
                .padding(.bottom, isSmall ? 8: 16)
        }
    }
    
    func line(axis: Axis) -> some View {
        WavyLine(segmentCount: isSmall ? 50: 100, seed: isSmall ? 200: 400, axis: axis)
            .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round))
            .foregroundColor(AppColor.color(hex: 0x000000))
            .if(axis == .horizontal, transform: {
                $0.frame(height: 2)
            })
            .if(axis == .vertical, transform: {
                $0.frame(width: 2)
            })
        
        
    }
    
    @ViewBuilder var momentView: some View {
        if let report = viewModel.weeklyReport {
            VStack(alignment: .leading, spacing: .zero) {
                Text("// A Moment to Reveal")
                    .textStyle(size: isSmall ? 8: 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                    .padding(.leading, isSmall ? 10:  20)
                    .padding(.top, isSmall ? 8 : 16)
                    .padding(.bottom, isSmall ? 7 : 14)
                
                Text(report.reportJson.gem.scene)
                    .textStyle(size: isSmall ? 9:  13, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, isSmall ? 10: 20)
                    .padding(.bottom, isSmall ? 8: 16)
                
                Text("The Evidence ")
                    .textStyle(size: isSmall ? 8: 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                    .padding(.leading, isSmall ? 10: 20)
                
                Text(report.reportJson.gem.evidence)
                    .textStyle(size: isSmall ? 9: 13, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, isSmall ? 10 : 20)
                    .padding(.top, isSmall ? 2: 4)
                
                
                Text("The insights")
                    .textStyle(size: isSmall ? 8: 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                    .padding(.leading, isSmall ? 10 : 20)
                    .padding(.top, isSmall ? 8: 16)
                
                Text(report.reportJson.gem.insight)
                    .textStyle(size: isSmall ? 9: 13, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, isSmall ? 10: 20)
                    .padding(.top, isSmall ? 2: 4)
                    .padding(.bottom, isSmall ? 8: 16)
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
            .padding(.horizontal,  isSmall ? 14: 32)
            .padding(.top, isSmall ? 14: 37)
        }
        
    }
    
    @ViewBuilder var overView: some View {
        if let report = viewModel.weeklyReport {
            VStack(alignment: .leading, spacing: .zero) {
                Text("// Your Analytical Overview")
                    .textStyle(size: isSmall ? 9: 11, color: AppColor.color(hex: 0x888888), fontFamily: .ibmPlexMonoRegular)
                    .padding(.leading, isSmall ? 10: 20)
                    .padding(.top, isSmall ? 10: 20)
                    .padding(.bottom, isSmall ? 7: 14)
                
                VStack(alignment: .leading, spacing: isSmall ? 8: 16) {
                    ForEach(report.reportJson.analyticalOverview, id: \.id) { section in
                        VStack(alignment: .leading, spacing: .zero) {
                            Text(section.title)
                                .textStyle(size: isSmall ? 12: 24, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
                            Text(section.content)
                                .textStyle(size: isSmall ? 9: 13, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 2)
                        }
                    }
                }
                .padding(.bottom, isSmall ? 8 : 16)
                .padding(.horizontal, isSmall ? 10 : 20)
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
            .padding(.horizontal,  isSmall ? 14: 32)
            .padding(.top, isSmall ? 14: 37)
        }
        
    }
}
