# Tech Stack

## Platform
- iOS 17+ (SwiftUI)
- Swift 5.9+
- Xcode project generated via XcodeGen (`project.yml` files)

## Build System
- XcodeGen for project file generation
- Fastlane for CI/CD (TestFlight distribution)
- Swift Package Manager for the Network module (`core/Network/Package.swift`)
- XcodeGen project configs for other core modules

## Key Libraries
- Lottie 4.5.1 (animations, via UIComponent module)
- Combine (reactive data flow)
- SwiftUI (all UI)

## Core Modules (under `core/`)
| Module | Product Name | Purpose |
|---|---|---|
| Network | LTNetwork | HTTP client, interceptors, request/response pipeline |
| Common | LTCommon | Feature toggles, dependency injection |
| Persistence | Persistence | KeyChain and UserDefaults storage abstractions |
| UIComponent | UIComponent | Shared UI components, fonts, colors, Lottie animations |

## Common Commands

```bash
# Generate Xcode project from project.yml
cd fastlane && bundle exec fastlane generate_project

# Build and upload to TestFlight
bundle exec fastlane internal_test

# Run Network module tests (SPM)
cd core/Network && swift test
```

## Concurrency
- Swift Concurrency (async/await, actors) throughout
- `@MainActor` for UI-bound classes and published properties
- `@unchecked Sendable` used on classes with manual thread safety
