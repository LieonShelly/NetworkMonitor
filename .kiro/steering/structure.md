# Project Structure

## Architecture: MVVM + Coordinator + Clean Architecture

```
.
├── app/LTApp/                    # Main iOS application
│   ├── LTApp.xcworkspace         # Open this in Xcode
│   ├── LTApp.xcodeproj/
│   ├── API/api.md                # Backend API documentation
│   ├── LTApp/
│   │   ├── Source/
│   │   │   ├── App/              # App entry point, AppDelegate, feature config, variants
│   │   │   ├── Common/           # App-level shared utilities
│   │   │   ├── Domain/           # Feature modules (see below)
│   │   │   ├── Extensions/       # Swift type extensions (Date, View)
│   │   │   └── Service/          # Service layer (see below)
│   │   └── Resource/             # Assets.xcassets, images, icons
│   ├── LTAppTests/
│   └── LTAppUITests/
├── core/                         # Shared framework modules
│   ├── Common/                   # LTCommon: feature toggles, DI container
│   ├── Network/                  # LTNetwork: ApiClient, interceptors, request/response models
│   ├── Persistence/              # KeyChain/UserDefaults storage protocols
│   └── UIComponent/              # Shared UI: buttons, colors, fonts, Lottie, text styles
├── fastlane/                     # Fastlane config, XcodeGen project templates
├── certs/                        # Signing certificates and provisioning profiles
└── .github/workflows/            # CI/CD (currently empty)
```

## Domain Layer (`Source/Domain/`)
Each feature is a folder containing its View, ViewModel, and supporting types:
- `Calendar/` — Calendar grid with reflection history, Metal/SVG icon rendering
- `Coordinator/` — Navigation coordinators (App, Home, PreHome, UserHome)
- `Detail/` — Reflection detail and answer views
- `Home/` — Main home screen (Model/View/ViewModel subfolders)
- `Insights/` — Weekly reports, report history, coin animations
- `Notification/` — Push notification handling
- `Onboarding/` — First-launch onboarding (View/ViewModel subfolders)
- `QuestionLib/` — Question library browsing
- `SignIn/` — Apple ID authentication
- `Splash/` — Launch screen
- `Submit/` — Answer submission flow
- `Thread/` — Threaded question categories
- `User/` — User profile and settings

## Service Layer (`Source/Service/`)
Clean Architecture with Repository + UseCase pattern:
- `DTO/` — Data Transfer Objects (API response models, `Decodable`)
- `Auth/` — Session management, token provider, auth repository + use cases
- `Reflection/` — Reflection CRUD (Model/Repository/Request/UseCase)
- `Report/` — Weekly reports (Model/Repository/Request/UseCase)
- `Icon/` — Icon generation status
- `User/` — User flow, QoD strategy
- `Interceptor/` — Network interceptors (auth token, refresh, logout)
- Root files: `AppDataService`, `AppDataWithAuthorizationService` (service locator aggregating all use cases)

## Conventions
- ViewModels are `ObservableObject` classes, typically `@MainActor`
- Use cases follow `{Action}{Entity}UseCase` naming with a `{Name}UseCaseType` protocol
- Repositories follow `{Entity}Repository` with `{Name}RepositoryType` protocol
- DTOs are `Decodable` structs suffixed with `DTO`
- Domain models are plain structs without the DTO suffix
- Coordinators manage `NavigationPath` and conform to the `Coordinator` protocol
- Dependency injection via `InjectionValues` (property wrapper `@Injected`)
- Feature toggles via `FeatureToggle` with rollout stages
