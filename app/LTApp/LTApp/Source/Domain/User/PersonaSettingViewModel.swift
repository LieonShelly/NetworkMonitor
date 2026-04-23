//
//  PersonaSettingViewModel.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/23.
//

import Combine
import Foundation

@MainActor
final class PersonaSettingViewModel: ObservableObject, @unchecked Sendable {
    let dataService: any AppDataWithAuthorizationServiceful
    private var cancellables: Set<AnyCancellable> = .init()
    init(dataService: any AppDataWithAuthorizationServiceful) {
        self.dataService = dataService
    }
}
