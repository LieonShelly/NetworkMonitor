# Project Structure

```
├── app/LTApp/LTApp/
│   ├── Source/
│   │   ├── App/              # App entry point, AppDelegate, feature config
│   │   ├── Common/           # Shared app-level utilities (Paginator, LoadMoreFooter)
│   │   ├── Domain/           # Feature modules (View + ViewModel per feature)
│   │   │   ├── Coordinator/  # Navigation coordinators (AppCoordinator, HomeCoordinator, PreHomeCoordinator)
│   │   │   ├── Calendar/
│   │   │   ├── Detail/
│   │   │   ├── Home/
│   │   │   ├── Insights/     # Weekly reports UI
│   │   │   ├── Onboarding/
│   │   │   ├── SignIn/
│   │   │   ├── Splash/
│   │   │   ├── Submit/       # Daily reflection submission
│   │   │   ├── Thread/
│   │   │   └── User/
│   │   ├── Extensions/       # Swift type extensions
│   │   └── Service/          # Data layer
│   │       ├── Auth/
│   │       ├── DTO/           # Data Transfer Objects (API response models)
│   │       ├── Icon/
│   │       ├── Interceptor/   # Network interceptors (Auth, RefreshToken, Logout)
│   │       ├── Reflection/
│   │       ├── Report/        # Organized as: Model/ Repository/ Request/ UseCase/
│   │       └── User/
│   ├── Resource/              # Assets.xcassets, images
│   └── API/                   # API documentation (api.md)
├── core/                      # Reusable framework modules
│   ├── Network/               # LTNetwork (SPM package + XcodeGen)
│   ├── Common/                # LTCommon (feature toggles, DI)
│   ├── Persistence/           # KeyChain/UserDefaults abstractions
│   └── UIComponent/           # Shared UI (buttons, text styles, Lottie, colors)
├── certs/                     # Signing certificates and provisioning profiles
└── fastlane/                  # Fastlane config, XcodeGen project settings
```

## Architecture Patterns

### MVVM + Coordinator
- Each feature in `Domain/` has `View/` (SwiftUI) and `ViewModel/` folders
- ViewModels are `ObservableObject` classes, injected via `@StateObject` or `@EnvironmentObject`
- Coordinators (`AppCoordinator`, `HomeCoordinator`, `PreHomeCoordinator`) manage navigation as `@StateObject`s

### Clean Architecture Service Layer
Each service domain (e.g., `Report/`) follows this structure:
- `Model/` — Domain models (plain Swift structs)
- `DTO/` — Decodable API response types with `toDomain()` mapping
- `Request/` — API request definitions conforming to `Request` protocol (enum-based)
- `Repository/` — Protocol + implementation, calls `ApiClient` and maps DTO → Domain
- `UseCase/` — Protocol + implementation, single-responsibility business operations

### Dependency Wiring
- `AppCoordinator` constructs the full dependency graph at launch
- `AppDataWithAuthorizationService` acts as a service locator exposing all use cases via lazy properties
- Use cases are accessed through protocol-typed properties (e.g., `any FetchWeeklyReportsListUseCaseType`)

### Networking
- `ApiClient` handles request execution with interceptor chain and retry logic
- Interceptors: `AuthInterceptor` (attach token), `RefreshTokenInterceptor` (refresh expired tokens), `LogoutInterceptor` (handle forced logout)
- Requests are enums conforming to `Request` protocol with `endPoint`, `method`, and `payload`
- SSE streaming support via `sendSSERequest`
