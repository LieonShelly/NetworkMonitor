//
//  NewInsightsHisotryListView.swift
//  LTApp
//

import SwiftUI
import UIComponent

struct NewInsightsHistoryListView: View {
    @ObservedObject var viewModel: InsightsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                currentWeekHeader
                historySection
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40 + 16 * 2)
        }
        .refreshable {
            try? await viewModel.fetchHistory()
        }
        .onFirstAppear {
            Task.detached {
                try? await viewModel.fetchHistory()
                try? await viewModel.fetchHistoryHeaderCurrentWeekIcons()
            }
        }
    }

    private var currentWeekHeader: some View {
        VStack(spacing: .zero) {
            // "CURRENT WEEK" label + count
            HStack {
                Text("CURRENT WEEK")
                    .textStyle(font: .annotation, color: AppColor.greyDark)
                Spacer()
                Text(iconCountText)
                    .textStyle(font: .annotation, color: AppColor.greyDark)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)

            // Icon row
            iconRow
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.horizontal, 24)
            
            if let currentIcons =  viewModel.currentIcons,
               !currentIcons.icons.isEmpty,
               currentIcons.minAnswersToGenerateReport <= currentIcons.icons.count {
                Button {
                    viewModel.onTapHistoryHeader()
                } label: {
                    Text("ready to print")
                        .textStyle(font: .body, color: AppColor.oat)
                        .frame(maxWidth: .infinity)
                        .frame(height: 41)
                        .background {
                            Image(.roundedBg).resizable()
                                .renderingMode(.template)
                                .foregroundStyle(AppColor.greyDark)
                        }
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                Button {
                    viewModel.onTapHistoryHeader()
                } label: {
                    Text("go to arcade")
                        .textStyle(font: .body, color: AppColor.greyDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 41)
                        .background {
                            Image(.roundedBg).resizable()
                        }
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background {
            Image(.rectCover).resizable()
        }
    }

    private var iconCountText: String {
        guard let currentIcons = viewModel.currentIcons else { return "" }
        return currentIcons.minAnswersToGenerateReport <= currentIcons.icons.count ? "FULL" : "\(currentIcons.icons.count)/\(currentIcons.minAnswersToGenerateReport)"
    }

    @ViewBuilder
    private var iconRow: some View {
        let processorId = "metal.icon.processor.v3_thickness_2"
        HStack(spacing: 8) {
            ForEach(0..<viewModel.weeklyIcons.count, id: \.self) { index in
                let iconStyle = viewModel.weeklyIcons[index]
                switch iconStyle {
                case .normal(let icon):
                    CoinIconView(url: icon.url, processorId: processorId)
                        .frame(width: 32, height: 32)
                case .plus:
                    Circle()
                        .fill(Color.clear)
                        .stroke(
                            AppColor.black,
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(AppColor.black)
                        }
                        .onTapGesture {
                            viewModel.onTapAdd()
                        }
                case .empty:
                    Circle()
                        .fill(Color.clear)
                        .stroke(
                            AppColor.black,
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                        .frame(width: 32, height: 32)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var historySection: some View {
        let allItems = viewModel.unreadHisotrys + viewModel.readHisotrys
        if !allItems.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text("HISTORY")
                    .textStyle(font: .annotation, color: AppColor.greyMedium)
                    .padding(.top, 24)

                ForEach(Array(allItems.enumerated()), id: \.element.id) { index, item in
                    // Year separator: show when it's the first item or the year changes
                    if shouldShowYearSeparator(for: item, in: allItems, at: index) {
                        Text(item.periodStart.yearDesc())
                            .textStyle(font: .annotation, color: AppColor.color(hex: 0x888888))
                    }

                    NewHistoryItemRow(history: item)
                        .contentShape(.rect)
                        .onTapGesture {
                            Task {
                                try? await viewModel.didTapHistoryItem(item)
                            }
                        }
                        .onAppear {
                            if item.id == allItems.last?.id {
                                Task { await viewModel.loadMoreHistory() }
                            }
                        }
                }
            }

            LoadMoreFooter(
                state: viewModel.reportsPaginator.loadMoreState,
                onRetry: { await viewModel.loadMoreHistory() }
            )
        }
    }

    private func shouldShowYearSeparator(
        for item: WeeklyReportSummary,
        in items: [WeeklyReportSummary],
        at index: Int
    ) -> Bool {
        guard index > 0 else { return false }
        let previousYear = items[index - 1].periodStart.yearDesc()
        let currentYear = item.periodStart.yearDesc()
        return currentYear != previousYear
    }
}

