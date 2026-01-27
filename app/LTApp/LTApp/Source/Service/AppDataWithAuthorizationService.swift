//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import Persistence

public protocol AppDataWithAuthorizationServiceful {
    var authUseCasse: any AuthUseCaseType { get }
    var submitAnswerUseCase: any SubmitAnswerUseCaseType { get }
    var fetchCategoriesUseCase: any FetchCategoriesUseCaseType { get }
    var fetchHeadQuestionUseCase: any FetchHeadQuestionUseCaseType { get }
    var fetchOnboardingSentenceUseCase: any FetchOnboardingSentenceUseCaseType { get }
    var calendarReflectionsUseCase: any CalendarReflectionsUseCaseType { get }
    var threadQuestionsUseCase: any FetchThreadQuestionsUseCaseType { get }
    var fetchQuestionsWithCategoryUseCase: any FetchQuestionsWithCategoryUseCaseType { get }
    var pinQuestionUseCase: any PinQuestionUseCaseType { get }
    var fetchHistoryAnswersUseCase: any FetchHistoryAnswersUseCaseType { get }
    var fetchTodayQuestionsUseCase: any FetchTodayQuestionsUseCaseType { get }
    var onboardingAccessUseCase: any OnboardingAccessUseCaseType { get }
    var queryIconStatusUseCase: any QueryIconGeneratingStatusUseCaseType { get }
    var userManagementService: any UserManagementServiceful { get }
    var postNotificationDeviceTokenUseCase: any PostNotificationDeviceTokenUseCaseType { get }
    var notificationFlagUseCase: any NotificationFlagUseCaseType { get }
    var deleteAnswerUseCase: any DeleteAnswersUseCaseType { get }
}

public final class AppDataWithAuthorizationService: AppDataWithAuthorizationServiceful, @unchecked Sendable {
    private let authRepository: any AuthRepositoryType
    private let reflectionRepository: any ReflectionRepositoryType
    private let iconRepositroy: any IconRepositoryType
    private let storage: any KeyValueStorageType
    private let keyDataStorage: any KeyDataStorageType
    public let userManagementService: any UserManagementServiceful
    private let notificationRepository: any NotificationRepositoryType
    
    public init(authRepository: any AuthRepositoryType,
                reflectionRepository: any ReflectionRepositoryType,
                iconRepositroy: any IconRepositoryType,
                notificationRepository: any NotificationRepositoryType,
                storage: any KeyValueStorageType,
                keyDataStorage: any KeyDataStorageType) {
        self.authRepository = authRepository
        self.reflectionRepository = reflectionRepository
        self.storage = storage
        self.iconRepositroy = iconRepositroy
        self.userManagementService = UserManagementService()
        self.notificationRepository = notificationRepository
        self.keyDataStorage = keyDataStorage
    }
    
    public lazy var authUseCasse: any AuthUseCaseType = {
        AuthUseCase(repository: authRepository)
    }()
    
    public lazy var submitAnswerUseCase: any SubmitAnswerUseCaseType = {
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
    
    public lazy var calendarReflectionsUseCase: any CalendarReflectionsUseCaseType = {
        CalendarReflectionsUseCase(repository: reflectionRepository)
    }()
    
    public lazy var threadQuestionsUseCase: any FetchThreadQuestionsUseCaseType = {
        FetchThreadQuestionsUseCase(repository: reflectionRepository)
    }()
    
    public lazy var fetchQuestionsWithCategoryUseCase: any FetchQuestionsWithCategoryUseCaseType = {
        FetchQuestionsWithCategoryUseCase(repository: reflectionRepository)
    }()
    
    public lazy var pinQuestionUseCase: any PinQuestionUseCaseType = {
        PinQuestionUseCase(repository: reflectionRepository)
    }()
    
    public lazy var fetchHistoryAnswersUseCase: any FetchHistoryAnswersUseCaseType = {
        FetchHistoryAnswersUseCase(repository: reflectionRepository)
    }()
    
    public lazy var fetchTodayQuestionsUseCase: any FetchTodayQuestionsUseCaseType = {
        FetchTodayQuestionsUseCase(repository: reflectionRepository)
    }()
    
    public lazy var onboardingAccessUseCase: any OnboardingAccessUseCaseType = {
        OnboardingAccessUseCase(storage: storage)
    }()
    
    public lazy var queryIconStatusUseCase: any QueryIconGeneratingStatusUseCaseType = {
        QueryIconGeneratingStatusUseCase(repository: iconRepositroy)
    }()
    
    public lazy var postNotificationDeviceTokenUseCase: any PostNotificationDeviceTokenUseCaseType = {
        PostNotificationDeviceTokenUseCase(repository: notificationRepository)
    }()
    
    public lazy var notificationFlagUseCase: any NotificationFlagUseCaseType = {
        NotificationFlagUseCase(storage: keyDataStorage)
    }()
    
    public lazy var deleteAnswerUseCase: any DeleteAnswersUseCaseType = {
        DeleteAnswersUseCase(repository: reflectionRepository)
    }()
}
