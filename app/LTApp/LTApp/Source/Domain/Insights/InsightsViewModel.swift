//
//  InsightsViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/4.
//


import SwiftUI

@Observable
class InsightsViewModel: @unchecked Sendable {
    let dataService: any AppDataWithAuthorizationServiceful
   @MainActor var weeklyReport: WeeklyReport?
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
    }
    
    func featchData() async throws {
       let report = try await dataService.fetchWeeklyReportUseCase.execute(week: nil)
        await MainActor.run {
            self.weeklyReport = report
        }
    }
    
    deinit {
        print("deinit-InsightsViewModel")
    }
}
