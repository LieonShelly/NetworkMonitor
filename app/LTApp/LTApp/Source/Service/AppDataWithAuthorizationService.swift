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
    var todayQuestionVisibilityUseCase: any TodayQuestionVisibilityUseCaseType { get }
    var onboardingAccessUseCase: any OnboardingAccessUseCaseType { get }
    var queryIconStatusUseCase: any QueryIconGeneratingStatusUseCaseType { get }
    var userManagementService: any UserManagementServiceful { get }
    var postNotificationDeviceTokenUseCase: any PostNotificationDeviceTokenUseCaseType { get }
    var notificationFlagUseCase: any NotificationFlagUseCaseType { get }
    var deleteAnswerUseCase: any DeleteAnswersUseCaseType { get }
    var updateStrategyUseCase: any UpdateStrategyUseCaseType { get }
    
    var fetchQodStrategyOptionsUseCase: any FetchQodStrategyOptionsUseCaseType { get }
    var fetchWeeklyReportUseCase: any FetchWeeklyReportUseCaseType { get }
    var fetchWeeklyReportCurrentIconsUseCase: any FetchWeeklyReportCurrentIconsUseCaseType { get }
    var fetchWeeklyReportsListUseCase: any FetchWeeklyReportsListUseCaseType { get }
    var fetchReadWeeklyReportsUseCase: any FetchReadWeeklyReportsUseCaseType { get }
    var fetchUnreadWeeklyReportsUseCase: any FetchUnreadWeeklyReportsUseCaseType { get }
    var markWeeklyReportReadUseCase: any MarkWeeklyReportReadUseCaseType { get }
    var saveTimezoneUseCase: any SaveTimezoneUseCaseType { get }
    var updateNicknameUseCase: any UpdateNicknameUseCaseType { get }
    var fetchReminderUseCase: any FetchReminderUseCaseType { get }
    var updateReminderUseCase: any UpdateReminderUseCaseType { get }
    var fetchPersonasUseCase: any FetchPersonasUseCaseType { get }
    var updateReportPersonaUseCase: any UpdateReportPersonaUseCaseType { get }
    var markIconReadUseCase: any MarkIconReadUseCaseType { get }
}

public final class AppDataWithAuthorizationService: AppDataWithAuthorizationServiceful, @unchecked Sendable {
    private let authRepository: any AuthRepositoryType
    private let reflectionRepository: any ReflectionRepositoryType
    private let iconRepositroy: any IconRepositoryType
    private let storage: any KeyValueStorageType
    private let keyDataStorage: any KeyDataStorageType
    public let userManagementService: any UserManagementServiceful
    private let notificationRepository: any NotificationRepositoryType
    private let userFlowRepository: any UserFlowRepositoryType
    private let reportRepository: any ReportRepositoryType
    
    public init(authRepository: any AuthRepositoryType,
                reflectionRepository: any ReflectionRepositoryType,
                userFlowRepository: any UserFlowRepositoryType,
                iconRepositroy: any IconRepositoryType,
                notificationRepository: any NotificationRepositoryType,
                reportRepository: any ReportRepositoryType,
                storage: any KeyValueStorageType,
                keyDataStorage: any KeyDataStorageType) {
        self.authRepository = authRepository
        self.reflectionRepository = reflectionRepository
        self.userFlowRepository = userFlowRepository
        self.storage = storage
        self.iconRepositroy = iconRepositroy
        self.userManagementService = UserManagementService(repository: userFlowRepository)
        self.notificationRepository = notificationRepository
        self.keyDataStorage = keyDataStorage
        self.reportRepository = reportRepository
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

    public lazy var todayQuestionVisibilityUseCase: any TodayQuestionVisibilityUseCaseType = {
        TodayQuestionVisibilityUseCase(storage: keyDataStorage)
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
    
    public lazy var updateStrategyUseCase: any UpdateStrategyUseCaseType = {
        UpdateStrategyUseCase(repository: userFlowRepository)
    }()
    
    public lazy var fetchQodStrategyOptionsUseCase: any FetchQodStrategyOptionsUseCaseType = {
        FetchQodStrategyOptionsUseCase(repository: userFlowRepository)
    }()
    
    public lazy var fetchWeeklyReportUseCase: any FetchWeeklyReportUseCaseType = {
        return FetchWeeklyReportUseCase(repository: reportRepository)
    }()
    
    public lazy var fetchWeeklyReportCurrentIconsUseCase: any FetchWeeklyReportCurrentIconsUseCaseType = {
        return FetchWeeklyReportCurrentIconsUseCase(repository: reportRepository)
    }()
    
    public lazy var fetchWeeklyReportsListUseCase: any FetchWeeklyReportsListUseCaseType = {
        return FetchWeeklyReportsListUseCase(repository: reportRepository)
    }()
    
    public lazy var fetchReadWeeklyReportsUseCase: any FetchReadWeeklyReportsUseCaseType = {
        return FetchReadWeeklyReportsUseCase(repository: reportRepository)
    }()
    
    public lazy var fetchUnreadWeeklyReportsUseCase: any FetchUnreadWeeklyReportsUseCaseType = {
        return FetchUnreadWeeklyReportsUseCase(repository: reportRepository)
    }()
    
    public lazy var markWeeklyReportReadUseCase: any MarkWeeklyReportReadUseCaseType = {
        return MarkWeeklyReportReadUseCase(repository: reportRepository)
    }()
    
    public lazy var saveTimezoneUseCase: any SaveTimezoneUseCaseType = {
        return SaveTimezoneUseCase(repository: userFlowRepository)
    }()
    
    public lazy var updateNicknameUseCase: any UpdateNicknameUseCaseType = {
        return UpdateNicknameUseCase(repository: userFlowRepository)
    }()
    
    public lazy var fetchReminderUseCase: any FetchReminderUseCaseType = {
        return FetchReminderUseCase(repository: userFlowRepository)
    }()
    
    public lazy var updateReminderUseCase: any UpdateReminderUseCaseType = {
        return UpdateReminderUseCase(repository: userFlowRepository)
    }()
    
    public lazy var fetchPersonasUseCase: any FetchPersonasUseCaseType = {
        return FetchPersonasUseCase(repository: userFlowRepository)
    }()
    
    public lazy var updateReportPersonaUseCase: any UpdateReportPersonaUseCaseType = {
        return UpdateReportPersonaUseCase(repository: userFlowRepository)
    }()
    
    public lazy var markIconReadUseCase: any MarkIconReadUseCaseType = {
        return MarkIconReadUseCase(repository: iconRepositroy)
    }()
}
