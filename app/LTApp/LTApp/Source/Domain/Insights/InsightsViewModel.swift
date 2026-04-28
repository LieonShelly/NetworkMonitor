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
    @MainActor @Published var weeklyIcons: [ConinIconStyle] = []
    @MainActor @Published var unreadHisotrys: [WeeklyReportSummary] = []
    @MainActor @Published var readHisotrys: [WeeklyReportSummary] = []
    @MainActor @Published var reportsPaginator: Paginator<WeeklyReportSummary>!
    @Published var arcadeState: ArcadeViewState = .unFull
    weak var router: InsightsRouter?
    var isFull: Bool {
        guard let currentIcons else { return false }
        let isFull = currentIcons.minAnswersToGenerateReport <= currentIcons.icons.count
            && currentIcons.minAnswersToGenerateReport != 0
        return isFull
    }
    var todayQuestions: [Question] = []
    var goToQoTFlow: (() -> Void)?
    
    enum ArcadeViewState {
        case countingDown
        case readyToPrint
        case unread
        case unFull
    }
    
    init(dataService: any AppDataWithAuthorizationServiceful,) {
        self.dataService = dataService
        self.reportsPaginator = Paginator { [dataService] cursor in
            let list = try await dataService.fetchWeeklyReportsListUseCase.execute(limit: 20, cursor: cursor, isRead: nil)
            return (list.reports, list.pagination)
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
    

    @MainActor
    func generateReport() async throws {
        guard weeklyReport == nil else {
            router?.push(.printing)
            return
        }
        let report = try await dataService.fetchWeeklyReportUseCase.execute(week: nil)
        self.weeklyReport = report
        router?.push(.printing)
        
    }
    
    func fetchHistory() async throws {
        await reportsPaginator.loadFirst()
        let newUnread = reportsPaginator.items.filter { $0.readAt == nil }
        let newRead = reportsPaginator.items.filter { $0.readAt != nil }
        await MainActor.run {
            self.unreadHisotrys = newUnread
            self.readHisotrys = newRead
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
        let report = try await dataService.fetchWeeklyReportUseCase.execute(week: history.week)
        await MainActor.run {
            self.weeklyReport = report
            router?.push(history.readAt == nil ? .printing : .reported)
        }
        if history.readAt == nil {
            let result = try await dataService.markWeeklyReportReadUseCase.execute(week: history.week)
            if var unread = unreadHisotrys.first(where: { $0.id == history.id }) {
                unread.readAt = result.readAt
                var updatedRead = readHisotrys
                updatedRead.append(unread)
                updatedRead.sort(by: { $0.periodStart > $1.periodEnd })
                var updatedUnread = unreadHisotrys
                updatedUnread.removeAll(where: { $0.id == history.id })
                self.readHisotrys = updatedRead
                self.unreadHisotrys = updatedUnread
            }
        }
    }
    
    func fetchDataTodayQuestions() async throws {
        let questions = try await dataService.fetchTodayQuestionsUseCase.execute()
        self.todayQuestions = questions
    }
    
    @MainActor
    func onTapHistoryHeader() {
        router?.popToRoot()
    }
    
    @MainActor
    func onTapAdd() {
        goToQoTFlow?()
    }
    
    
    @MainActor
    func refreshArcadeState() async {
        guard let currentIcons = currentIcons else {
            arcadeState = .unFull
            return
        }
        
        let isFull = currentIcons.minAnswersToGenerateReport <= currentIcons.icons.count
            && currentIcons.minAnswersToGenerateReport != 0
        if Date.isWeekDay {
            if isFull {
                arcadeState = .readyToPrint
            } else {
                arcadeState = .unFull
            }
        } else {
            if !unreadHisotrys.isEmpty {
                arcadeState = .unread
            } else if isFull {
                arcadeState = .countingDown
            } else {
                arcadeState = .unFull
            }
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
