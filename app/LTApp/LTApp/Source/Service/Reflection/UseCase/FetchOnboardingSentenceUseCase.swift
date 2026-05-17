//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol FetchOnboardingSentenceUseCaseType: Sendable {
    func execute() async throws -> OnboardingSentence
    var currentValue: OnboardingSentence? { get set }
}


public class FetchOnboardingSentenceUseCase: FetchOnboardingSentenceUseCaseType, @unchecked Sendable {
    private let repository: any ReflectionRepositoryType
    public var currentValue: OnboardingSentence? = nil
    
    init(repository: any ReflectionRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> OnboardingSentence {
        guard currentValue == nil else {
            return currentValue!
        }
        let sencetence = try await repository.fetchOnboardingSentence()
        self.currentValue = sencetence
        return sencetence
    }
}
