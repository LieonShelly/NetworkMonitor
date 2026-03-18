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
    
    deinit {
        print("deinit-InsightsViewModel")
    }
}
