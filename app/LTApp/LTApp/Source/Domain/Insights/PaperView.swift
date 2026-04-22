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
        .padding(.horizontal, value(32))
        .defaultBackground()
    }
    
    
    @ViewBuilder func iconListView(report: WeeklyReport) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: value(6)) {
                ForEach(report.icons, id: \.iconId) { iconData in
                    IconView(iconData: iconData)
                }
            }
        }
        .frame(height: value(56))
        .padding(.horizontal, value(20))
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
                .padding(.horizontal, value(20))
                .padding(.top, value(24))
                .padding(.bottom, value(8))
        }
    }
    
    @ViewBuilder func summaryView(report: WeeklyReport) -> some View {
        let summary = report.reportJson.summary
        Text(summary)
            .textStyle(font: .body, color: AppColor.greyDark)
            .padding(.horizontal, value(20))
            .padding(.bottom, value(42))
    }
    
    
    @ViewBuilder func categoryView(report: WeeklyReport) -> some View {
        let divider =  ZStack(alignment: .bottom) {
            Rectangle()
                .frame(width: value(15), height: value(15))
            Image(.vector137)
                .resizable()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        
        if let count = report.count {
            VStack(alignment: .leading, spacing: .zero) {
                Text("// The Little Invoice")
                    .textStyle(font: .annotation, color: AppColor.grey)
                    .padding(.bottom, value(28))
                VStack(alignment: .leading, spacing: value(16)) {
                    ForEach(count.categories, id: \.id) { category in
                        HStack(spacing: value(8)) {
                            Rectangle()
                                .fill(Color.random)
                                .frame(width: value(24), height: value(24))
                            Text(category.name)
                                .textStyle(font: .annotation, color: AppColor.greyDark)
                            divider
                            
                            Text("\(category.count)")
                                .textStyle(font: .annotation, color: AppColor.greyDark)
                                
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    divider
                        .padding(.bottom, value(5))
                    
                    HStack(spacing: value(8)) {
                        Text("total")
                            .textStyle(font: .annotation, color: AppColor.greyDark)
                        
                        divider
                        
                        Text("\(count.total) stamps")
                            .textStyle(font: .annotation, color: AppColor.greyDark)
                    }
                    
                }
            }
            .padding(.horizontal, value(20))
          
            
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
                        .frame(width: value(100))
                        .padding(.top, value(40))
                }
    
                Text(gem.evidence)
                    .textStyle(font: .title, color: AppColor.greyDark)
                    .padding(.top, value(20))
                
                Text(gem.insight)
                    .textStyle(font: .body, color: AppColor.greyDark)
                    .padding(.top, value(16))
          
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, value(20))
        .padding(.top, value(45))
    }
    
    @ViewBuilder func remindersView(report: WeeklyReport) -> some View {
        let reminders = report.reportJson.reminders

        VStack(alignment: .leading, spacing: .zero) {
            Text("// A few little inspo for next week...")
                .textStyle(font: .annotation, color: AppColor.grey)
                .padding(.bottom, value(22))
            
            VStack(alignment: .leading, spacing: value(15)) {
                ForEach(reminders, id: \.self) { text in
                    HStack(alignment: .top, spacing: value(16)) {
                        Image(.rectangle64)
                            .resizable()
                            .frame(width: value(16), height: value(16))
                            .padding(.top, value(4))
                        
                        Text(text)
                            .textStyle(font: .title)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
          
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, value(20))
        .padding(.vertical, value(42))
        
        Image(.subtract)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: value(20))
            .frame(maxWidth: .infinity)
            .offset(y: 2)
    }
        
    
    func line(axis: Axis, segmentCount: Int = 100, seed: Int = 400) -> some View {
        WavyLine(segmentCount: isSmall ? segmentCount / 2: segmentCount, seed: isSmall ? Int(seed / 2): seed, axis: axis)
            .stroke(style: StrokeStyle(lineWidth: isSmall ? 1 : 2, lineCap: .round))
            .foregroundColor(AppColor.color(hex: 0x000000))
            .if(axis == .horizontal, transform: {
                $0.frame(height: 2)
            })
            .if(axis == .vertical, transform: {
                $0.frame(width: 2)
            })
        
        
    }
    
    private func value(_ value: CGFloat) -> CGFloat {
        isSmall ? value * 0.5 : value
    }
}

