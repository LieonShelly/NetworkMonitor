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
            case .readyToPrint:
                titleView
                ReadyToPrintView(viewModel: viewModel)
                    .padding(.bottom, 112)
                    .transition(.opacity.animation(.easeInOut))
            case .reported:
                ReportedView(viewModel: viewModel)
                    .transition(.opacity.animation(.easeInOut))
            case .history:
                titleView
                ReportHistoryView(viewModel: viewModel)
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
            if viewModel.state != .history, viewModel.state != .printing {
                Button {
                    viewModel.state = .history
                } label: {
                    if viewModel.unreadHisotrys.isEmpty {
                        Image(.folderOpen)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(AppColor.color(hex: 0x000000))
                    } else {
                        Image(.folderOpenDot)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(AppColor.color(hex: 0x000000))
                    }
                }
            }
            HStack(spacing: .zero) {
                Spacer()
                Text("AI Insights")
                    .textStyle(size: 33)
                Spacer()
            }
        }
        .frame(height: 32)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }
}
