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
            try? await viewModel.fetchHisotryData()
        }
        .onFirstAppear {
            Task.detached {
                try? await viewModel.fetchHisotryData()
            }
        }
    }
    
    @ViewBuilder
    var histroyView: some View {
        HStack {
            Text("unread".uppercased())
                .textStyle(size: 12, fontFamily: .poppinsRegular)
                .padding(.top, 15)
                .padding(.bottom, 12)
            Spacer()
        }
        
        LazyVStack(spacing: 16) {
            if !viewModel.unreadHisotrys.isEmpty {
                ForEach(viewModel.unreadHisotrys, id: \.id) { history in
                    UnreadReportHistoryRow(history: history)
                        .onTapGesture {
                            Task {
                               try? await viewModel.didTapHistoryItem(history)
                            }
                        }
                }
            }
           
        }
        
        if !viewModel.readHisotrys.isEmpty {
            HStack {
                Text("HISTORY".uppercased())
                    .textStyle(size: 12, fontFamily: .poppinsRegular)
                    .padding(.top, 15)
                    .padding(.bottom, 12)
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(viewModel.readHisotrys, id: \.id) { history in
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
}
