# Network Monitor

A lightweight, passive network traffic monitoring tool for iOS/macOS development. Built with SwiftUI and URLProtocol, it captures and displays all HTTP/HTTPS requests made by your app without modifying existing network code.

## Features

- **Passive Monitoring**: Captures all URLSession requests without affecting normal network behavior
- **Floating Ball UI**: Draggable, non-intrusive floating button with expandable request list
- **Request Details**: View complete request/response headers, body (with JSON pretty-printing), status codes, and timing
- **Export & Copy**: Export individual request logs or long-press to copy details to clipboard
- **Performance Optimized**: Limits stored entries and body sizes to prevent memory issues
- **Thread-Safe**: Uses modern Swift concurrency with `@Observable` and `@MainActor`

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      App Layer                          │
│                   (Your Application)                    │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   NetworkMonitorModule                  │
│         Public API for start/stop/clear               │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   NetworkMonitorStore                  │
│              @Observable - Thread-safe state            │
└─────────────────────────────────────────────────────────┘
          │                                   │
          ▼                                   ▼
┌─────────────────────┐            ┌─────────────────────┐
│  NetworkMonitorCore │            │  FloatingBallView   │
│  URLProtocol reg    │            │  (SwiftUI UI)       │
└─────────────────────┘            └─────────────────────┘
          │                                   │
          ▼                                   ▼
┌─────────────────────────────────────────────────────────┐
│              NetworkMonitorURLProtocol                  │
│            Intercepts & records HTTP requests           │
└─────────────────────────────────────────────────────────┘
```

## File Structure

```
core/Common/Source/NetworkMonitor/
├── Model/
│   ├── NetworkMonitorEntry.swift        # Data model for a single request
│   └── NetworkMonitorConfiguration.swift # Configuration options
├── Core/
│   ├── NetworkMonitorCore.swift          # URLProtocol registration
│   └── NetworkMonitorURLProtocol.swift   # Request interception & forwarding
├── Store/
│   └── NetworkMonitorStore.swift        # @Observable state management
├── UI/
│   ├── FloatingBallView.swift            # Draggable floating button
│   ├── NetworkMonitorPanelView.swift     # Main panel with request list
│   ├── RequestRowView.swift             # Individual request row
│   ├── RequestDetailView.swift          # Expandable request details
│   └── ShareSheet.swift                 # iOS share sheet wrapper
└── NetworkMonitorModule.swift           # Public module entry point
```

## Requirements

- **iOS 17.0+** / **macOS 14.0+**
- Swift 5.9+
- SwiftUI

## Installation

The module is part of the `Common` framework. Ensure `core/Common` is included in your project build.

## Quick Start

### 1. Start Monitoring

In your app entry point (`AppDelegate` or `LTAppApp`):

```swift
#if DEBUG
NetworkMonitorModule.start()
#endif
```

### 2. Add Floating Ball to UI

In your root view hierarchy:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            
            #if DEBUG
            NetworkMonitorModule.floatingBall
            #endif
        }
    }
}
```

### 3. Done

The floating ball will appear in the bottom-right corner. Tap to open the request list.

## Usage

### Basic Operations

```swift
// Start monitoring (typically in app launch)
NetworkMonitorModule.start()

// Stop monitoring
NetworkMonitorModule.stop()

// Clear all captured entries
NetworkMonitorModule.clear()

// Access the store directly if needed
let entries = NetworkMonitorStore.shared.entries
let isExpanded = NetworkMonitorStore.shared.isExpanded
```

### Configuration

```swift
let config = NetworkMonitorConfiguration(
    maxEntries: 100,     // Maximum entries to store (default: 100)
    maxBodySize: 1_048_576  // Max body size in bytes (default: 1MB)
)

// Pass configuration when creating store
let store = NetworkMonitorStore(configuration: config)
```

## UI Components

### Floating Ball
- Draggable button in bottom-right corner
- Shows badge with request count
- Tap to expand/collapse panel

### Request List
- Displays all captured requests in reverse chronological order
- Shows method badge (color-coded), URL path, status, and duration
- Tap to expand details, long-press to copy

### Request Details
- **Export Button**: Share complete request info via system share sheet
- **Request Section**: Headers + Body (JSON pretty-printed)
- **Response Section**: Status, Duration, Headers + Body
- Expandable/collapsible sections

## How It Works

### URLProtocol Interception

`NetworkMonitorURLProtocol` is registered to `URLSessionConfiguration.default.protocolClasses`. It works by:

1. **Intercepting**: The protocol's `canInit(with:)` determines which requests to capture
2. **Recording**: Captures request metadata (URL, method, headers, body)
3. **Forwarding**: Creates an ephemeral session to forward the actual request
4. **Recording Response**: Captures response data as it streams back
5. **Storing**: Saves complete request/response to `NetworkMonitorStore`

### Thread Safety

- `@Observable` provides automatic thread-safe state management
- `@MainActor` ensures UI updates happen on the main thread
- `NetworkMonitorCore` uses `NSLock` for safe registration/unregistration

## Limitations

1. **Post-Registration Only**: Only captures requests made after `start()` is called
2. **URLSession Only**: Does not capture requests made via other networking libraries unless they use URLSession internally
3. **Debug Builds Only**: Should be wrapped in `#if DEBUG` for release builds

## Data Model

### NetworkMonitorEntry

```swift
public struct NetworkMonitorEntry: Identifiable, Sendable {
    public let id: UUID
    public let url: URL
    public let method: String
    public let requestHeaders: [String: String]
    public let requestBody: Data?
    public var responseHeaders: [String: String]?
    public var responseBody: Data?
    public var statusCode: Int?
    public var error: Error?
    public let startTime: Date
    public var endTime: Date?
}
```

### Computed Properties

```swift
entry.duration              // TimeInterval?
entry.state                 // .loading, .success, .failed
entry.formattedDuration     // "123ms" or "1.23s"
entry.prettyPrintedRequestBody  // JSON formatted
entry.prettyPrintedResponseBody  // JSON formatted
entry.formattedExportText    // Full export format
entry.formattedCopyText     // Copy-friendly format
```

## Best Practices

1. **Start Early**: Call `start()` as early as possible in app lifecycle to capture initialization requests
2. **Use Debug Guards**: Always wrap monitoring code in `#if DEBUG`
3. **Large Bodies**: Be aware of body size limits for very large responses
4. **Memory Management**: The store automatically limits entries, but very large bodies may still consume memory

## Contributing

When adding features:

1. Update this README with new functionality
2. Update `docs/network_monitor_design.md` with design details
3. Ensure thread safety with `@MainActor` and proper locking
4. Add appropriate `@Observable` conformance

## License

Internal use - LittleThings
