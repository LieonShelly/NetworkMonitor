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
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
        dataService
            .userManagementService
            .user
            .map { $0?.qodStrategy }
            .sink { strategy in
                Task { @MainActor in
                    var list: [QuestionOfTodaySettingItem] = [
                        .init(icon: .random, selected: false, title: "Random", description: "Prompt randomly from question library ", qodStrategy: .random),
                        .init(icon: .star, selected: false, title: "Pinned", description: "Only prompt from pinned questions ", qodStrategy: .pinned),
                        .init(icon: .combine, selected: false, title: "Mixed", description: "Prompt from pinned questions & library ",  qodStrategy: .mixed),
                    ]
                    if let index = list.firstIndex(where: { $0.qodStrategy == strategy}) {
                        list[index] = list[index].copyWith(selected: true)
                    }
                    self.list = list
                }
            }
            .store(in: &cancellables)
    }
    
    
    func onTap(_ item: QuestionOfTodaySettingItem) async {
       await dataService.updateStrategyUseCase.execute(item.qodStrategy)
        try? await dataService.userManagementService.fetchUserInfo()
    }
}
