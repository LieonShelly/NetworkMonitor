//
//  QuestionOfTodaySettingViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/4.
//

import SwiftUI
import Combine

class QuestionOfTodaySettingViewModel: ObservableObject, @unchecked Sendable {
    let dataService: any AppDataWithAuthorizationServiceful
    @MainActor @Published var list: [QuestionOfTodaySettingItem] = []
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
    }
    
    func fetchData() async {
        await MainActor.run {
            list = [
                .init(icon: .star, selected: true, title: "Random", description: "Prompt randomly from question library "),
                .init(icon: .star, selected: false, title: "Pinned", description: "Only prompt from pinned questions "),
                .init(icon: .star, selected: false, title: "Mixed", description: "Prompt from pinned questions & library "),
            ]
        }
    }
}


struct QuestionOfTodaySettingItem {
    let icon: ImageResource
    let selected: Bool
    let title: String
    let description: String
    var id: UUID = UUID()
}
