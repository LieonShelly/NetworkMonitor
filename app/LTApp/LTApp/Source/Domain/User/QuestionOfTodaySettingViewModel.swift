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
    }
    
    @MainActor
    func fetchData() async throws {
        var list = await dataService.fetchQodStrategyOptionsUseCase.execute()
        dataService
            .userManagementService
            .user
            .sink { userInfo in
                if let index = list.firstIndex(where: {$0.qodStrategyValue == userInfo?.qodStrategy.rawValue}) {
                    list[index] = list[index].copyWith(selected: true)
                }
                self.list = list
            }
            .store(in: &cancellables)
    }
    
    func onTap(_ item: QuestionOfTodaySettingItem) async {
        await dataService.updateStrategyUseCase.execute(item.qodStrategyValue)
        await MainActor.run {
            if let index = list.firstIndex(where: { $0.id == item.id }) {
                var list = self.list.map { $0.copyWith(selected: false )}
                list[index] = list[index].copyWith(selected: true)
                self.list = list
            }
        }
    }
}
