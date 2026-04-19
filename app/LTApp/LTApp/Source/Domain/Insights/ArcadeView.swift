//
//  ArcadeView.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/19.
//

import SwiftUI
import UIComponent

struct ArcadeView: View {
    @ObservedObject var viewModel: InsightsViewModel
    private let processorId = "metal.icon.processor.v3_thickness_2"
    
    var body: some View {
        VStack(spacing: .zero) {
            tokenHeader
            screen
            controlPanel
        }
        .onFirstAppear {
            Task {
                try? await viewModel.fetchHistoryHeaderCurrentWeekIcons()
            }
        }
    }
    
    var tokenHeader: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                iconCountView
                iconRow
            }
            .padding(.leading, 48)
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background {
                Image(.tokenBg)
                    .resizable()
            }
            .padding(.bottom, 26)
            
            HStack(spacing: .zero) {
                Image(.vector128)
                    .resizable()
                    .frame(width: 12, height: 28)
                Spacer()
                Image(.vector129)
                    .resizable()
                    .frame(width: 12, height: 28)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private var iconCountView: some View {
        HStack(spacing: 10) {
            Text(iconCountText)
                .textStyle(size: 20, fontFamily: .dsDigital)
                .textCase(.uppercase)
            
            Image(systemName: "arrowtriangle.right.fill")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(Color.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Image(.rectangle53)
                .resizable()
        )
        .padding(.trailing, 24)
    }
    
    private var iconCountText: String {
        guard let currentIcons = viewModel.currentIcons else { return "0 / 0" }
        let count = currentIcons.icons.count
        let total = currentIcons.minAnswersToGenerateReport
        return "\(count) / \(total)"
    }
    
    // MARK: - Token 图标行
    @ViewBuilder
    private var iconRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(0..<viewModel.weeklyIcons.count, id: \.self) { index in
                    let iconStyle = viewModel.weeklyIcons[index]
                    switch iconStyle {
                    case .normal(let icon):
                        CoinIconView(url: icon.url, processorId: processorId)
                    case .empty, .plus:
                        Circle()
                            .fill(Color.clear)
                            .stroke(
                                AppColor.black,
                                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                            )
                            .frame(width: 28, height: 28)
                    }
                }
            }
        }
    }
    
    // MARK: - Screen
    var screen: some View {
        VStack {
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(.screen)
                .resizable()
        )
        .padding(.horizontal, 18)
        .offset(y: -2)
    }
    
    // MARK: - Control Panel
    var controlPanel: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: .zero) {
                Image(.vector130)
                    .resizable()
                    .frame(width: 20, height: 69)
                Spacer()
                Image(.vector131)
                    .resizable()
                    .frame(width: 20, height: 69)
                    .offset(x: -1)
            }
            
            WavyLine(segmentCount: 200, seed: 200, axis: .horizontal)
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .foregroundColor(AppColor.black)
                .frame(height: 1)
        }
        .offset(y: -12)
        .frame(height: 85)
    }
}
