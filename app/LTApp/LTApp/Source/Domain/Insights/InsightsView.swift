//
//  InsightsView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/10/30.
//

import SwiftUI
import UIComponent

struct InsightsView: View {
    @StateObject var viewModel: InsightsViewModel
    
    init(viewModel: InsightsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            switch viewModel.state {
            case .arcade:
                titleView
                ArcadeView(viewModel: viewModel)
                    .padding(.bottom, 70)
                    .transition(.opacity.animation(.easeInOut))
            case .reported:
                ReportedView(viewModel: viewModel)
                    .transition(.opacity.animation(.easeInOut))
            case .history:
                titleView
//                ReportHistoryView(viewModel: viewModel)
                NewInsightsHistoryListView(viewModel: viewModel)
                    .transition(.opacity.animation(.easeInOut))
            case .printing:
                titleView
                PrinterView(viewModel: viewModel)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .defaultBackground()
    }
    
    var titleView: some View {
        ZStack(alignment: .trailing) {
            if viewModel.state != .reported || viewModel.state != .printing {
                Button {
                    viewModel.state = viewModel.state == .history ? .arcade : .history
                } label: {
                    if viewModel.state == .arcade {
                        Image(.folderOpen)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(AppColor.color(hex: 0x000000))
                    } else {
                        Image(.arcade)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(AppColor.color(hex: 0x000000))
                    }
                }
            }
            HStack(spacing: .zero) {
                Spacer()
                Text("Time Arcade")
                    .textStyle(size: 33)
                Spacer()
            }
        }
        .frame(height: 32)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }
}
