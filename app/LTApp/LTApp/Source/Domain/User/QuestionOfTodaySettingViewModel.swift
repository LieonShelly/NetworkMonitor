//
//  QuestionOfTodaySettingViewModel.swift
//  LTApp
//

import SwiftUI
import Combine

class QuestionOfTodaySettingViewModel: ObservableObject, @unchecked Sendable {
    let dataService: any AppDataWithAuthorizationServiceful
    @MainActor @Published var list: [QuestionOfTodaySettingItem] = []
    @MainActor @Published var selectedValue: String?
    @MainActor @Published var isSaving: Bool = false
    private var originalSelectedValue: String?
    private var cancellables: Set<AnyCancellable> = .init()
    
    @MainActor
    var hasChanges: Bool {
        selectedValue != nil && selectedValue != originalSelectedValue
    }
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
    }
    
    @MainActor
    func fetchData() async throws {
        let list = await dataService.fetchQodStrategyOptionsUseCase.execute()
        dataService
            .userManagementService
            .user
            .sink { [weak self] userInfo in
                guard let self else { return }
                self.list = list
                if let strategy = userInfo?.qodStrategy.rawValue {
                    self.selectedValue = strategy
                    self.originalSelectedValue = strategy
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func select(_ item: QuestionOfTodaySettingItem) {
        selectedValue = item.qodStrategyValue
    }
    
    @MainActor
    func save() async {
        guard let selectedValue, hasChanges else { return }
        isSaving = true
        await dataService.updateStrategyUseCase.execute(selectedValue)
        originalSelectedValue = selectedValue
        isSaving = false
    }
}
