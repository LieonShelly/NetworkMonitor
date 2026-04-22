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
        VStack(alignment: .leading, spacing: .zero) {
            if let weeklyReport = viewModel.weeklyReport {
                iconListView(report: weeklyReport)
                glanceView(report: weeklyReport)
                summaryView(report: weeklyReport)
                categoryView(report: weeklyReport)
                oneLittleMomentView(report: weeklyReport)
                remindersView(report: weeklyReport)
            }
        }
       
        .overlay(content: {
            HStack {
                line(axis: .vertical, segmentCount: 200, seed: 800)
                Spacer()
                line(axis: .vertical, segmentCount: 200, seed: 800)
            }
        })
        .background(AppColor.white)
        .padding(.horizontal, 32)
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(report.icons, id: \.iconId) { iconData in
                    IconView(iconData: iconData)
                }
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
        .overlay(alignment: .bottom, content: {
            line(axis: .horizontal)
        })
        .overlay(alignment: .top, content: {
            line(axis: .horizontal)
        })
    }
    
    @ViewBuilder func glanceView(report: WeeklyReport) -> some View {
        if let glance = report.reportJson.glance {
            Text(glance)
                .textStyle(font: .title, color: AppColor.greyDark)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder func summaryView(report: WeeklyReport) -> some View {
        let summary = report.reportJson.summary
        Text(summary)
            .textStyle(font: .body, color: AppColor.greyDark)
            .padding(.horizontal, 20)
            .padding(.bottom, 42)
    }
    
    
    @ViewBuilder func categoryView(report: WeeklyReport) -> some View {
        let divider =  ZStack(alignment: .bottom) {
            Rectangle()
                .frame(width: 15, height: 15)
            Image(.vector137)
                .resizable()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        
        if let count = report.count {
            VStack(alignment: .leading, spacing: .zero) {
                Text("// The Little Invoice")
                    .textStyle(font: .annotation, color: AppColor.grey)
                    .padding(.bottom, 28)
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(count.categories, id: \.id) { category in
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color.random)
                                .frame(width: 24, height: 24)
                            Text(category.name)
                                .textStyle(font: .annotation, color: AppColor.greyDark)
                            divider
                            
                            Text("\(category.count)")
                                .textStyle(font: .annotation, color: AppColor.greyDark)
                                
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    divider
                        .padding(.bottom, 5)
                    
                    HStack(spacing: 8) {
                        Text("total")
                            .textStyle(font: .annotation, color: AppColor.greyDark)
                        
                        divider
                        
                        Text("\(count.total) stamps")
                            .textStyle(font: .annotation, color: AppColor.greyDark)
                    }
                    
                }
            }
            .padding(.horizontal, 20)
          
            
        }
    }
    
    @ViewBuilder func oneLittleMomentView(report: WeeklyReport) -> some View {
        let gem = report.reportJson.gem
        VStack(alignment: .leading, spacing: .zero) {
            Text("// The Little Invoice")
                .textStyle(font: .annotation, color: AppColor.grey)
            
            VStack(spacing: .zero) {
                if let gemIcon = gem.icon {
                    OriginalIconView(url: gemIcon.url) {}
                        .frame(width: 100)
                        .padding(.top, 40)
                }
    
                Text(gem.evidence)
                    .textStyle(font: .title, color: AppColor.greyDark)
                    .padding(.top, 20)
                
                Text(gem.insight)
                    .textStyle(font: .body, color: AppColor.greyDark)
                    .padding(.top, 16)
          
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 45)
    }
    
    @ViewBuilder func remindersView(report: WeeklyReport) -> some View {
        let reminders = report.reportJson.reminders

        VStack(alignment: .leading, spacing: .zero) {
            Text("// A few little inspo for next week...")
                .textStyle(font: .annotation, color: AppColor.grey)
                .padding(.bottom, 22)
            
            VStack(alignment: .leading, spacing: 15) {
                ForEach(reminders, id: \.self) { text in
                    HStack(alignment: .top, spacing: 16) {
                        Image(.rectangle64)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(.top, 4)
                        
                        Text(text)
                            .textStyle(font: .title)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
          
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 42)
        
        Image(.subtract)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 20)
            .frame(maxWidth: .infinity)
            .offset(y: 2)
    }
        
    
    
    @ViewBuilder func summaryContentView(report: WeeklyReport) -> some View {
            Text(report.reportJson.summary)
                .textStyle(size: isSmall ? 9: 13, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, isSmall ? 10: 20)
                .padding(.bottom, isSmall ? 8: 16)
        }
    
    
    func line(axis: Axis, segmentCount: Int = 100, seed: Int = 400) -> some View {
        WavyLine(segmentCount: isSmall ? segmentCount / 2: segmentCount, seed: isSmall ? Int(seed / 2): seed, axis: axis)
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .foregroundColor(AppColor.color(hex: 0x000000))
            .if(axis == .horizontal, transform: {
                $0.frame(height: 2)
            })
            .if(axis == .vertical, transform: {
                $0.frame(width: 2)
            })
        
        
    }
}
