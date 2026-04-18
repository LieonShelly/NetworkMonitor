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
            try? await viewModel.fetchHisotryData()
        }
        .onFirstAppear {
            Task.detached {
                try? await viewModel.fetchHisotryData()
                try? await viewModel.fetchHistoryHeaderCurrentWeekIcons()
            }
        }
    }

    // MARK: - Current Week Header

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
                .padding(.top, 12)
                .padding(.horizontal, 24)

            // "go to arcade" button
            Button {
                viewModel.onTapHistoryHeader()
            } label: {
                Text("go to arcade")
                    .textStyle(font: .body, color: AppColor.greyDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 41)
                    .background(AppColor.oat)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.greyDark, lineWidth: 2)
                    }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.greyDark, lineWidth: 2)
        }
    }

    private var iconCountText: String {
        guard let currentIcons = viewModel.currentIcons else { return "" }
        return "\(currentIcons.icons.count)/\(currentIcons.minAnswersToGenerateReport)"
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
        }
    }

    // MARK: - History Section

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

// MARK: - History Item Row (matches Figma card design)

private struct NewHistoryItemRow: View {
    let history: WeeklyReportSummary

    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            DefaultOriginalIconImageView(url: history.icon.url)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 6) {
                Text(periodText)
                    .textStyle(font: .annotation, color: AppColor.greyMedium)

                Text(history.summary)
                    .textStyle(font: .title, color: AppColor.greyMedium)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(AppColor.oat)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.greyMedium, lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// Formats period as "22 - 28 FEB" matching the Figma design
    private var periodText: String {
        let calendar = AppCalendar.current
        let startDay = calendar.component(.day, from: history.periodStart)
        let endDay = calendar.component(.day, from: history.periodEnd)
        let endMonth = history.periodEnd.monthDesc(isShort: true).uppercased()

        if calendar.isDate(history.periodStart, equalTo: history.periodEnd, toGranularity: .month) {
            return "\(startDay) - \(endDay) \(endMonth)"
        } else {
            let startMonth = history.periodStart.monthDesc(isShort: true).uppercased()
            return "\(startDay) \(startMonth) - \(endDay) \(endMonth)"
        }
    }
}
