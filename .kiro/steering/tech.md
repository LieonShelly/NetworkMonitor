# Tech Stack

## Platform
- iOS (Swift, SwiftUI)
- Minimum deployment: iOS 17+ (uses `onChange(of:)` two-parameter variant, Swift concurrency with `@MainActor`)
- Xcode project with workspace (`LTApp.xcworkspace`)

## Project Generation
- XcodeGen (`project.yml` files in each core module and `fastlane/project/`)
- Generate project: `fastlane generate_project`

## Build & Deploy
- Fastlane for CI/CD
- Ruby 3.2.2, Bundler >= 2.0.0, Fastlane 2.228.0
- Bundle ID: `com.little.things`
- Build to TestFlight: `bundle exec fastlane internal_test`
- Generate Xcode project: `bundle exec fastlane generate_project`
- Install dependencies: `bundle install`

## Core Frameworks (local)
- `LTNetwork` — HTTP client with interceptor chain (auth, refresh token, logout)
- `LTCommon` — Feature toggles, dependency injection
- `Persistence` — KeyChain and UserDefaults storage abstraction
- `UIComponent` — Shared UI components, colors, fonts, Lottie animations

## Third-Party Dependencies
- Lottie 4.5.1 (via SPM, used in UIComponent)

## Key Patterns
- Swift Concurrency (`async/await`, `@MainActor`, `Sendable`)
- Combine for reactive bindings in coordinators
- Protocol-oriented design — all use cases and repositories have protocol types
- `@unchecked Sendable` on classes with internal synchronization

## Signing & Provisioning
- Certificates and provisioning profiles stored in `certs/`
- Ad-hoc, App Store, and Development profiles available
- App Store Connect API key used for TestFlight uploads
