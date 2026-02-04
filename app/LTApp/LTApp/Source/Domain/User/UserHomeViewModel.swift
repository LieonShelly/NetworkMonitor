//
//  UserHomeViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/4.
//

import Combine

final class UserHomeViewModel: @preconcurrency BaseViewModelType, ObservableObject, @unchecked Sendable {
    var subPageRoute: InnerPageRouteState = .none
    @MainActor @Published var userName: String = ""
    let dataService: any AppDataWithAuthorizationServiceful
    
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
    }

    
}
