//
//  FetchQodStrategyOptionsUseCaseType.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/9.
//

import Foundation

public protocol FetchQodStrategyOptionsUseCaseType {
    func execute() async -> [QuestionOfTodaySettingItem]
}

public class FetchQodStrategyOptionsUseCase: FetchQodStrategyOptionsUseCaseType, @unchecked Sendable {
    private let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async -> [QuestionOfTodaySettingItem] {
        (try? await repository.fetchQodStrategyOptions()) ?? []
    }
}
