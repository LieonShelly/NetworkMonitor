//
//  ReportHistoryView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/22.
//

import SwiftUI
import UIComponent
import SpriteKit
import Kingfisher

struct ReportHistoryView: View {
    @ObservedObject var viewModel: InsightsViewModel
    
    init(viewModel: InsightsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ReportHistoryHeader(viewModel: viewModel)
                histroyView
            }
            .padding(.horizontal, 36)
        }
        .refreshable {
            try? await viewModel.fetchData()
            try? await viewModel.fetchHistory()
        }
    }
    
    @ViewBuilder
    var histroyView: some View {
        HStack {
            Text("HISTORY")
                .textStyle(size: 12, fontFamily: .poppinsRegular)
                .padding(.top, 15)
                .padding(.bottom, 12)
            Spacer()
        }
        
        LazyVStack(spacing: 16) {
            ForEach(viewModel.historys, id: \.id) { history in
                ReportHistoryRow(history: history)
                    .onTapGesture {
                        Task {
                           try? await viewModel.didTapHistoryItem(history)
                        }
                    }
            }
        }
    }
}


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
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.color(hex: 0x888888), lineWidth: 1)
        }
    }
}



struct ReportHistoryHeader: View {
    @ObservedObject var viewModel: InsightsViewModel
    var processorId: String = "metal.icon.processor.v3_thickness_2"
    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(.acrade)
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 120)
                .padding(.leading, 4)
                .padding(.top, 4)
            
            Spacer()
            VStack (alignment: .leading, spacing: .zero) {
                HStack(alignment: .top, spacing: .zero) {
                    HStack(spacing: .zero) {
                        Text("YOUR COINS")
                            .textStyle(size: 9, color: AppColor.color(hex: 0xffffff), fontFamily: .poppinsRegular)
                            .lineLimit(1)
                        
                        Image(.rightPloly)
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(AppColor.color(hex: 0xffffff))
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .rotationEffect(.degrees(90))
                            .padding(.leading, 4)
                        
                    }
                    .padding(8)
                    .background(AppColor.color(hex: 0x000000))
                    .frame(minWidth: 80)
                    
                    Spacer()
                    
                    Text("22 - 28 Feb")
                        .textStyle(size: 14, fontFamily: .ibmPlexMonoRegular)
                }
                Spacer()
                iconList
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.color(hex: 0x888888), lineWidth: 1)
        }
    }
    
    @ViewBuilder
    var iconList: some View {
        
        let columns: Int = 5
        let columnW: CGFloat = 28
        let columnsG = (0 ..< columns).map { _ in GridItem(.fixed(columnW), spacing: 10, alignment: .center)}
        let itemH: CGFloat = 28
        let count = viewModel.weeklyIcons.count
        LazyVGrid(columns: columnsG, spacing: 16) {
            ForEach(0 ..< count , id: \.self) { index in
                let iconStyle = viewModel.weeklyIcons[index]
                switch iconStyle {
                case .normal(let icon):
                    CoinIconView(url: icon.url, processorId: processorId)
                case.empty:
                    Circle()
                        .fill(Color.clear)
                        .stroke(AppColor.color(hex: 0x000000), style: .init(lineWidth: 1, lineCap: .square, lineJoin: .round, miterLimit: 0, dash: [4, 4], dashPhase: .zero))
                        .frame(width: itemH, height: itemH)
                    
                case .plus:
                    Circle()
                        .fill(Color.clear)
                        .stroke(AppColor.color(hex: 0x000000), style: .init(lineWidth: 1, lineCap: .square, lineJoin: .round, miterLimit: 0, dash: [4, 4], dashPhase: .zero))
                        .frame(width: itemH, height: itemH)
                        .overlay {
                            Image(.threadAdd)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .foregroundStyle(AppColor.color(hex: 0x000000))
                        }
                }
            }
        }
    }
}


