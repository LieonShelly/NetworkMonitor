//
//  InsightsViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/4.
//


import SwiftUI

final class InsightsViewModel: ObservableObject, @unchecked Sendable {
    let dataService: any AppDataWithAuthorizationServiceful
    @MainActor @Published var weeklyReport: WeeklyReport?
    @MainActor @Published var currentIcons: WeeklyReportCurrentIcons?
    @MainActor @Published var state: UIState = .history
    @MainActor @Published var weeklyIcons: [ConinIconStyle] = []
    @MainActor @Published var unreadHisotrys: [WeeklyReportSummary] = []
    @MainActor @Published var readHisotrys: [WeeklyReportSummary] = []
    
    enum UIState {
        case readyToPrint
        case reported
        case history
    }
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
    }
    
    func fetchData() async throws {
        let report = try await dataService.fetchWeeklyReportUseCase.execute(week: nil)
        let currentIcons = try await dataService.fetchWeeklyReportCurrentIconsUseCase.execute()
        await MainActor.run {
            self.weeklyReport = report
            self.currentIcons = currentIcons
            self.weeklyIcons = currentIcons.icons.map { .normal($0)}
            let normalCount = self.weeklyIcons.count
            if currentIcons.minAnswersToGenerateReport > self.weeklyIcons.count {
                self.weeklyIcons.append(.plus)
               let placeholders = (0 ..< currentIcons.minAnswersToGenerateReport - normalCount - 1).map { _ in ConinIconStyle.empty }
                self.weeklyIcons.append(contentsOf: placeholders)
            }
        }
    }
    
    @MainActor
    func generateReport() async throws {
        guard weeklyReport == nil else { return self.state = .reported }
        let report = try await dataService.fetchWeeklyReportUseCase.execute(week: nil)
        self.weeklyReport = report
        self.state = .reported
    }
    
    func fetchHistory() async throws {
       let list = try await dataService.fetchWeeklyReportsListUseCase.execute(limit: nil, cursor: nil, isRead: nil)
        let unRead = list.reports.filter({ $0.readAt == nil })
        let read = list.reports.filter({ $0.readAt != nil })
        await MainActor.run {
            self.unreadHisotrys = unRead
            self.readHisotrys = read
        }
    }
    
    @MainActor
    func didTapHistoryItem(_ history: WeeklyReportSummary) async throws {
        let report = try await dataService.fetchWeeklyReportUseCase.execute(week: history.week)
        await MainActor.run {
            self.weeklyReport = report
            self.state = .reported
        }
    }
    
    deinit {
        print("deinit-InsightsViewModel")
    }
}


enum ConinIconStyle {
    case normal(WeeklyReportIcon)
    case plus
    case empty
}
