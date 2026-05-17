//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import Combine

@MainActor
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
        dataService
            .userManagementService
            .user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                guard let self else { return }
                if let strategy = userInfo?.qodStrategy.rawValue {
                    self.selectedValue = strategy
                    self.originalSelectedValue = strategy
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func fetchData() async throws {
        let list = await dataService.fetchQodStrategyOptionsUseCase.execute()
        try? await dataService.userManagementService.fetchUserInfo()
        self.list = list
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
