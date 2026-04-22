//
//  InsightsView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/10/30.
//

import SwiftUI
import UIComponent

enum InsightsPage: Equatable, Hashable {
    case arcade
    case history
    case reported
    case printing
}

@MainActor
final class InsightsRouter: ObservableObject {
    @Published private(set) var stack: [InsightsPage] = [.arcade]
    
    var current: InsightsPage {
        stack.last ?? .arcade
    }
    
    func push(_ page: InsightsPage) {
        guard stack.last != page else { return }
        stack.append(page)
    }
    
    func pop() {
        guard stack.count > 1 else { return }
        stack.removeLast()
    }
    
    func popToRoot() {
        stack = [stack.first ?? .arcade]
    }
    
    func replace(_ page: InsightsPage) {
        guard !stack.isEmpty else {
            stack = [page]
            return
        }
        stack[stack.count - 1] = page
    }
}


struct InsightsView: View {
    @StateObject var viewModel: InsightsViewModel
    @StateObject private var router = InsightsRouter()
    
    init(viewModel: InsightsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: .zero) {
                titleView
                ArcadeView(viewModel: viewModel)
                    .padding(.bottom, 70)
            }
            .opacity(router.current == .arcade ? 1 : 0)
            .allowsHitTesting(router.current == .arcade)
            
            ForEach(Array(router.stack.enumerated()), id: \.element) { index, page in
                if page != .arcade {
                    pageView(for: page)
                        .transition(.opacity)
                        .zIndex(Double(index))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: router.stack)
        .defaultBackground()
        .environmentObject(router)
        .onAppear {
            viewModel.router = router
        }
    }
    
    @ViewBuilder
    private func pageView(for page: InsightsPage) -> some View {
        switch page {
        case .arcade:
            EmptyView()
        case .history:
            VStack(spacing: .zero) {
                titleView
                NewInsightsHistoryListView(viewModel: viewModel)
            }
        case .printing:
            VStack(spacing: .zero) {
                titleView
                PrinterView(viewModel: viewModel)
            }
        case .reported:
            ReportedView(viewModel: viewModel)
        }
    }
    
    var titleView: some View {
        FixedHeader(title: "Time Arcade", size: .plain, trailing: {
            if router.current != .reported && router.current != .printing {
                Button {
                    withAnimation {
                        if router.current == .history {
                            router.pop()
                        } else {
                            router.push(.history)
                        }
                    }
                } label: {
                    if router.current == .arcade {
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
        })
    }
}
