//
//  InsightsViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/4.
//


import SwiftUI

@MainActor
final class InsightsViewModel: ObservableObject, @unchecked Sendable {
    let dataService: any AppDataWithAuthorizationServiceful
    @MainActor @Published var weeklyReport: WeeklyReport?
    @MainActor @Published var currentIcons: WeeklyReportCurrentIcons?
    @MainActor @Published var state: UIState = .readyToPrint
    @MainActor @Published var weeklyIcons: [ConinIconStyle] = []
    @MainActor @Published var unreadHisotrys: [WeeklyReportSummary] = []
    @MainActor @Published var readHisotrys: [WeeklyReportSummary] = []
    @MainActor @Published var reportsPaginator: Paginator<WeeklyReportSummary>!
    @MainActor @Published var printUIState: ReadyToPrintUIState = .empty
    var todayQuestions: [Question] = []
    var goToQoTFlow: (() -> Void)?
    
    enum UIState {
        case readyToPrint
        case reported
        case history
        case printing
    }
    
    enum ReadyToPrintUIState {
        case readyToPrint
        case unread
        case empty
    }
    
    init(dataService: any AppDataWithAuthorizationServiceful,) {
        self.dataService = dataService
        self.reportsPaginator = Paginator { [dataService] cursor in
            let list = try await dataService.fetchWeeklyReportsListUseCase.execute(limit: 20, cursor: cursor, isRead: nil)
            return (list.reports, list.pagination)
        }
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
    
    func fetchCurrentWeekReport() async throws {
        let report = try await dataService.fetchWeeklyReportUseCase.execute(week: nil)
        await MainActor.run {
            self.weeklyReport = report
        }
    }
    
    func fetchHistoryHeaderCurrentWeekIcons() async throws {
        let currentIcons = try await dataService.fetchWeeklyReportCurrentIconsUseCase.execute()
        await MainActor.run {
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
    
    func fetchReadyToPrintData() async throws {
        let currentIcons = try await dataService.fetchWeeklyReportCurrentIconsUseCase.execute()
        let ready = currentIcons.minAnswersToGenerateReport <= currentIcons.icons.count
        var printUIState: ReadyToPrintUIState = .empty
        var unreads: [WeeklyReportSummary] = []
        
        if currentIcons.icons.isEmpty {
            printUIState = .empty
        } else if ready {
            printUIState = .readyToPrint
        } else {
            unreads = try await dataService.fetchUnreadWeeklyReportsUseCase.execute(limit: nil, cursor: nil).reports
            printUIState = !unreads.isEmpty ? .unread : .empty
            
        }
        await MainActor.run {
            self.printUIState = printUIState
            self.currentIcons = currentIcons
            self.unreadHisotrys = unreads
            self.weeklyIcons = currentIcons.icons.map { .normal($0)}
            let normalCount = self.weeklyIcons.count
            if currentIcons.minAnswersToGenerateReport > self.weeklyIcons.count {
                self.weeklyIcons.append(.plus)
               let placeholders = (0 ..< currentIcons.minAnswersToGenerateReport - normalCount - 1).map { _ in ConinIconStyle.empty }
                self.weeklyIcons.append(contentsOf: placeholders)
            }
        }
    }
    
    func fetchHisotryData() async throws {
        let currentIcons = try await dataService.fetchWeeklyReportCurrentIconsUseCase.execute()
        await reportsPaginator.loadFirst()
        await MainActor.run {
            self.currentIcons = currentIcons
            self.weeklyIcons = currentIcons.icons.map { .normal($0)}
            let normalCount = self.weeklyIcons.count
            if currentIcons.minAnswersToGenerateReport > self.weeklyIcons.count {
                self.weeklyIcons.append(.plus)
               let placeholders = (0 ..< currentIcons.minAnswersToGenerateReport - normalCount - 1).map { _ in ConinIconStyle.empty }
                self.weeklyIcons.append(contentsOf: placeholders)
            }
            self.unreadHisotrys = reportsPaginator.items.filter { $0.readAt == nil }
            self.readHisotrys = reportsPaginator.items.filter { $0.readAt != nil }
        }
    }
    
    @MainActor
    func generateReport() async throws {
        guard weeklyReport == nil else { return self.state = .printing }
        let report = try await dataService.fetchWeeklyReportUseCase.execute(week: nil)
        self.weeklyReport = report
        self.state = .printing
    }
    
    func fetchHistory() async throws {
        await reportsPaginator.loadFirst()
        await MainActor.run {
            self.unreadHisotrys = reportsPaginator.items.filter { $0.readAt == nil }
            self.readHisotrys = reportsPaginator.items.filter { $0.readAt != nil }
        }
    }
    
    @MainActor
    func loadMoreHistory() async {
        await reportsPaginator.loadMore()
        self.unreadHisotrys = reportsPaginator.items.filter { $0.readAt == nil }
        self.readHisotrys = reportsPaginator.items.filter { $0.readAt != nil }
    }
    
    @MainActor
    func didTapHistoryItem(_ history: WeeklyReportSummary) async throws {
        if history.readAt == nil {
            let result = try await dataService.markWeeklyReportReadUseCase.execute(week: history.week)
            if var unread = unreadHisotrys.filter({ $0.id == history.id }).first {
                unread.readAt = result.readAt
                readHisotrys.append(unread)
                readHisotrys.sort(by: { $0.periodStart > $1.periodEnd })
                unreadHisotrys.removeAll(where: { $0.id == history.id })
            }
        }
        let report = try await dataService.fetchWeeklyReportUseCase.execute(week: history.week)
        await MainActor.run {
            self.weeklyReport = report
            self.state = .reported
        }
    }
    
    func fetchDataTodayQuestions() async throws {
        let questions = try await dataService.fetchTodayQuestionsUseCase.execute()
        self.todayQuestions = questions
    }
    
    @MainActor
    func onTapHistoryHeader() {
        self.state = .readyToPrint
    }
    
    @MainActor
    func onTapAdd() {
        goToQoTFlow?()
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
