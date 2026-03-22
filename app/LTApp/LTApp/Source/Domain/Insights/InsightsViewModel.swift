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
    @MainActor @Published var state: UIState = .readyToPrint
    
    enum UIState {
        case readyToPrint
        case reported
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
        
    }
    
    deinit {
        print("deinit-InsightsViewModel")
    }
}
