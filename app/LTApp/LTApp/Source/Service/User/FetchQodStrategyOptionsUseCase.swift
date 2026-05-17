//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchQodStrategyOptionsUseCaseType: Sendable {
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
