//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol AppDataWithAuthorizationServiceful {
    var authUseCasse: any AuthUseCaseType { get }
    var submitAnswerUseCase: any SubmitAnswerUseType { get }
    var fetchCategoriesUseCase: any FetchCategoriesUseCaseType { get }
    var fetchHeadQuestionUseCase: any FetchHeadQuestionUseCaseType { get }
    var fetchOnboardingSentenceUseCase: any FetchOnboardingSentenceUseCaseType { get }
}

public final class AppDataWithAuthorizationService: AppDataWithAuthorizationServiceful, @unchecked Sendable {
    private let authRepository: any AuthRepositoryType
    private let reflectionRepository: any ReflectionRepositoryType
    
    public init(authRepository: any AuthRepositoryType,
                reflectionRepository: any ReflectionRepositoryType) {
        self.authRepository = authRepository
        self.reflectionRepository = reflectionRepository
    }
    
    public lazy var authUseCasse: any AuthUseCaseType = {
        AuthUseCase(repository: authRepository)
    }()
    
    public lazy var submitAnswerUseCase: any SubmitAnswerUseType = {
        SubmitAnswerUseCase(repository: reflectionRepository)
    }()
    
    public lazy var fetchCategoriesUseCase: any FetchCategoriesUseCaseType = {
        FetchCategoriesUseCase(repository: reflectionRepository)
    }()
    
    public lazy var fetchHeadQuestionUseCase: any FetchHeadQuestionUseCaseType = {
        FetchHeadQuestionUseCase(repository: reflectionRepository)
    }()
    
    public lazy var fetchOnboardingSentenceUseCase: any FetchOnboardingSentenceUseCaseType = {
        FetchOnboardingSentenceUseCase(repository: reflectionRepository)
    }()
}
