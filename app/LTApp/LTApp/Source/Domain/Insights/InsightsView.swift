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
                    .padding(.top, 33)
                    .transition(.opacity.animation(.easeInOut))
            case .reported:
                ReportedView(viewModel: viewModel)
                    .transition(.opacity.animation(.easeInOut))
            case .history:
                titleView
                ReportHistoryView(viewModel: viewModel)
                    .padding(.top, 33)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .onFirstAppear {
            Task.detached {
                try? await viewModel.fetchData()
                try? await viewModel.fetchHistory()
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
    
   
}
