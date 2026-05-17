//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol UpdateStrategyUseCaseType: Sendable {
    func execute(_ strategy: String) async
}

public class UpdateStrategyUseCase: UpdateStrategyUseCaseType, @unchecked Sendable {
    private let repository: any UserFlowRepositoryType
    
    public init(repository: any UserFlowRepositoryType) {
        self.repository = repository
    }
    
    public func execute(_ strategy: String) async {
        try? await repository.updateQodStrategy(strategy)
    }
}
