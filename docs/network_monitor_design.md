# Network Monitor - 详细设计文档

## 1. 概述

### 1.1 目的

开发一个独立于现有 `core/Network` 网络层的 API 调试工具，用于在开发/测试环境中捕获和展示 App 内所有 HTTP 请求的完整信息。

### 1.2 设计原则

- **独立性**：与现有网络层完全解耦，不修改任何现有代码
- **被动监听**：通过 `URLProtocol` 被动捕获请求，不影响正常业务逻辑
- **仅 Debug 环境**：仅在 Debug/Release-Debug 配置下启用

### 1.3 技术选型

| 组件 | 技术方案 |
|------|----------|
| 捕获机制 | `URLProtocol` 子类 |
| 状态管理 | `@Observable` (Swift 5.9+) |
| UI 框架 | SwiftUI |
| 存储位置 | `core/Common` |
| 最低 iOS 版本 | iOS 17.0 |

---

## 2. 架构设计

### 2.1 模块结构

```
core/Common/Source/
├── NetworkMonitor/
│   ├── Model/
│   │   ├── NetworkMonitorEntry.swift      # 单个请求的数据模型
│   │   └── NetworkMonitorConfiguration.swift  # 启动配置
│   ├── Core/
│   │   ├── NetworkMonitorURLProtocol.swift  # URLProtocol 实现
│   │   └── NetworkMonitorSessionManager.swift  # Session 管理器
│   ├── Store/
│   │   └── NetworkMonitorStore.swift      # 状态管理 (@Observable)
│   └── UI/
│       ├── FloatingBallView.swift         # 悬浮球组件
│       ├── NetworkMonitorPanelView.swift  # 展开面板
│       └── RequestDetailView.swift       # 请求详情视图
```

### 2.2 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        App 层                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            LTAppApp (入口)                           │   │
│  │  - 在 init() 中调用 NetworkMonitorStore.shared.start()│   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    core/Common 层                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           NetworkMonitorPanelView                    │   │
│  │  - 请求列表 (LazyVStack)                              │   │
│  │  - 展开详情 (RequestDetailView)                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▲                                 │
│                           │ @Binding                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            FloatingBallView                          │   │
│  │  - 可拖动悬浮球                                       │   │
│  │  - 点击展开/收起面板                                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▲                                 │
│                           │ @ObservedObject                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            NetworkMonitorStore                        │   │
│  │  @Observable - 线程安全的状态管理                       │   │
│  │  - entries: [NetworkMonitorEntry]                     │   │
│  │  - isExpanded: Bool                                   │   │
│  │  - isEnabled: Bool                                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▲                                 │
│                           │                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │        NetworkMonitorURLProtocol                     │   │
│  │  - 拦截所有 URLSession 请求                           │   │
│  │  - 记录请求/响应信息                                   │   │
│  │  - 转发请求到原始 URLSession                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ▲                                 │
│                           │                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      NetworkMonitorSessionManager                     │   │
│  │  - 注册/注销 URLProtocol                              │   │
│  │  - 创建转发用的 URLSession                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 核心组件设计

### 3.1 数据模型

#### NetworkMonitorEntry

```swift
public struct NetworkMonitorEntry: Identifiable, Sendable {
    public let id: UUID
    public let url: URL
    public let method: String
    public let requestHeaders: [String: String]
    public let requestBody: Data?
    public private(set) var responseHeaders: [String: String]?
    public private(set) var responseBody: Data?
    public private(set) var statusCode: Int?
    public private(set) var error: Error?
    public let startTime: Date
    public private(set) var endTime: Date?
    public private(set) var task: URLSessionTask?

    public var duration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    public var state: State {
        switch (statusCode, error, endTime) {
        case (_, _, nil): return .loading
        case (_, let err?, _): return .failed(err)
        case (200..<300, _, _): return .success
        case (let code?, _, _): return .failed(NSError(domain: "HTTP", code: code))
        case (nil, _, _): return .loading
        }
    }

    public enum State: Sendable {
        case loading
        case success
        case failed(Error)
    }

    // 辅助方法
    public var formattedDuration: String { ... }
    public var requestBodyString: String? { ... }
    public var responseBodyString: String? { ... }
    public var prettyPrintedRequestBody: String? { ... }
    public var prettyPrintedResponseBody: String? { ... }
}
```

### 3.2 URLProtocol 实现

#### NetworkMonitorURLProtocol

```swift
public class NetworkMonitorURLProtocol: URLProtocol {
    // 核心属性
    private var entry: NetworkMonitorEntry?
    private var session: URLSession?
    private var task: URLSessionTask?
    private var responseData = Data()

    public override class func canInit(with task: URLSessionTask) -> Bool {
        // 避免循环拦截
        guard task is URLSessionDataTask else { return false }
        return true
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        // 只拦截 HTTP/HTTPS 请求
        guard let scheme = request.url?.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else {
            return false
        }
        return true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override func startLoading() {
        guard let request = request,
              let url = request.url else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        // 创建监控条目
        entry = NetworkMonitorEntry(
            id: UUID(),
            url: url,
            method: request.httpMethod ?? "GET",
            requestHeaders: extractHeaders(from: request),
            requestBody: request.httpBody,
            startTime: Date()
        )

        // 记录到 Store
        Task { @MainActor in
            NetworkMonitorStore.shared.recordEntry(entry!)
        }

        // 使用专门的 session 转发请求（避免循环拦截）
        session = NetworkMonitorSessionManager.shared.forwardingSession
        task = session?.dataTask(with: request)
        task?.resume()
    }

    public override func stopLoading() {
        task?.cancel()
        task = nil
        session = nil
    }

    // MARK: - URLSessionDataDelegate

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.cancel)
            return
        }

        // 更新条目
        updateEntry { entry in
            entry.responseHeaders = extractHeaders(from: httpResponse)
            entry.statusCode = httpResponse.statusCode
            entry.endTime = Date()
            entry.responseBody = responseData
            entry.task = dataTask
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            updateEntry { entry in
                entry.error = error
                entry.endTime = Date()
            }
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}
```

### 3.3 Session 管理器

#### NetworkMonitorSessionManager

```swift
public final class NetworkMonitorSessionManager: @unchecked Sendable {
    public static let shared = NetworkMonitorSessionManager()

    private var _forwardingSession: URLSession?
    private let lock = NSLock()

    public var forwardingSession: URLSession {
        lock.lock()
        defer { lock.unlock() }
        if let session = _forwardingSession {
            return session
        }
        let session = createForwardingSession()
        _forwardingSession = session
        return session
    }

    private func createForwardingSession() -> URLSession {
        let config = URLSessionConfiguration.default
        // 不使用自定义 protocol，确保请求能正常转发
        config.protocolClasses = []
        return URLSession(configuration: config)
    }

    public func register() {
        var classes = URLProtocol.protocolClasses(for: .default)
        if !classes.contains(where: { $0 == NetworkMonitorURLProtocol.self }) {
            classes.insert(NetworkMonitorURLProtocol.self, at: 0)
            URLProtocol.setProperty(classes, forKey: "NetworkMonitorProtocols")
        }
    }

    public func unregister() {
        URLProtocol.setProperty([URLProtocol.self], forKey: "NetworkMonitorProtocols")
    }
}
```

### 3.4 状态管理

#### NetworkMonitorStore

```swift
@Observable
@MainActor
public final class NetworkMonitorStore {
    public static let shared = NetworkMonitorStore()

    public private(set) var entries: [NetworkMonitorEntry] = []
    public var isExpanded: Bool = false
    public var isEnabled: Bool = false

    private let maxEntries = 100  // 最多保存 100 条记录

    private init() {}

    public func start() {
        guard !isEnabled else { return }
        NetworkMonitorSessionManager.shared.register()
        isEnabled = true
    }

    public func stop() {
        guard isEnabled else { return }
        NetworkMonitorSessionManager.shared.unregister()
        isEnabled = false
    }

    public func clear() {
        entries.removeAll()
    }

    public func recordEntry(_ entry: NetworkMonitorEntry) {
        entries.insert(entry, at: 0)
        // 保持最多 100 条记录
        if entries.count > maxEntries {
            entries.removeLast()
        }
    }

    public func updateEntry(_ entry: NetworkMonitorEntry, update: (inout NetworkMonitorEntry) -> Void) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        var updated = entries[index]
        update(&updated)
        entries[index] = updated
    }
}
```

---

## 4. UI 组件设计

### 4.1 FloatingBallView

```swift
public struct FloatingBallView: View {
    @ObservedObject private var store = NetworkMonitorStore.shared

    @State private var position: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 150)
    @State private var isDragging = false

    private let ballSize: CGFloat = 50
    private let cornerRadius: CGFloat = 25

    public init() {}

    public var body: some View {
        Group {
            #if DEBUG
            ZStack {
                if store.isExpanded {
                    NetworkMonitorPanelView()
                        .frame(width: screenWidth * 0.85, height: screenHeight * 0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 5)
                }

                // 悬浮球
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: ballSize, height: ballSize)
                    .shadow(color: .accentColor.opacity(0.3), radius: isDragging ? 10 : 5)
                    .overlay {
                        Image(systemName: "network")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .position(position)
                    .gesture(dragGesture)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            store.isExpanded.toggle()
                        }
                    }

                // 请求计数 Badge
                if !store.entries.isEmpty && !store.isExpanded {
                    Text("\(min(store.entries.count, 99))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .position(x: position.x + 18, y: position.y - 18)
                }
            }
            #endif
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                position = value.location
            }
            .onEnded { value in
                isDragging = false
                // 限制在屏幕范围内
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                position.x = min(max(ballSize / 2, value.location.x), screenWidth - ballSize / 2)
                position.y = min(max(ballSize / 2, value.location.y), screenHeight - ballSize / 2)
            }
    }
}
```

### 4.2 NetworkMonitorPanelView

```swift
public struct NetworkMonitorPanelView: View {
    @ObservedObject private var store = NetworkMonitorStore.shared
    @State private var selectedEntry: NetworkMonitorEntry?

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // 请求列表
            if store.entries.isEmpty {
                emptyStateView
            } else {
                requestListView
            }
        }
        .background(Color(.systemBackground))
    }

    private var headerView: some View {
        HStack {
            Text("Network Monitor")
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Button(action: { store.clear() }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .disabled(store.entries.isEmpty)

            Button(action: { store.isExpanded = false }) {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "network.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No requests captured")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var requestListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.entries) { entry in
                    RequestRowView(entry: entry, isSelected: selectedEntry?.id == entry.id)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedEntry?.id == entry.id {
                                    selectedEntry = nil
                                } else {
                                    selectedEntry = entry
                                }
                            }
                        }

                    if selectedEntry?.id == entry.id {
                        RequestDetailView(entry: entry)
                    }
                }
            }
        }
    }
}
```

### 4.3 RequestRowView

```swift
public struct RequestRowView: View {
    let entry: NetworkMonitorEntry
    let isSelected: Bool

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Method Badge
                Text(entry.method)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(methodColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                // URL (truncated)
                Text(entry.url.path + entry.url.query.map { "?\($0)" } ?? "")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                // Status / Duration
                statusView
            }

            // 请求 URL (完整路径)
            Text(entry.url.absoluteString)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding()
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }

    private var methodColor: Color {
        switch entry.method {
        case "GET": return .green
        case "POST": return .blue
        case "PUT": return .orange
        case "PATCH": return .purple
        case "DELETE": return .red
        default: return .gray
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch entry.state {
        case .loading:
            ProgressView()
                .scaleEffect(0.7)
        case .success:
            HStack(spacing: 4) {
                Text("\(entry.statusCode ?? 0)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.green)
                Text("•")
                    .foregroundStyle(.secondary)
                Text(entry.formattedDuration)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        case .failed:
            HStack(spacing: 4) {
                Text("\(entry.statusCode ?? 0)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.red)
                Text("•")
                    .foregroundStyle(.secondary)
                Text(entry.formattedDuration)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

### 4.4 RequestDetailView

```swift
public struct RequestDetailView: View {
    let entry: NetworkMonitorEntry

    @State private var requestExpanded = true
    @State private var responseExpanded = true

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Request Section
            expandableSection(
                title: "Request",
                icon: "arrow.up.circle.fill",
                color: .blue,
                isExpanded: $requestExpanded
            ) {
                headersSection(title: "Headers", headers: entry.requestHeaders)
                if let body = entry.prettyPrintedRequestBody {
                    bodySection(title: "Body", content: body)
                }
            }

            Divider()
                .padding(.horizontal)

            // Response Section
            expandableSection(
                title: "Response",
                icon: "arrow.down.circle.fill",
                color: .green,
                isExpanded: $responseExpanded
            ) {
                statusSection
                headersSection(title: "Headers", headers: entry.responseHeaders ?? [:])
                if let body = entry.prettyPrintedResponseBody {
                    bodySection(title: "Body", content: body)
                }
            }
        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground))
    }

    private func expandableSection(
        title: String,
        icon: String,
        color: Color,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { isExpanded.wrappedValue.toggle() }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            if isExpanded.wrappedValue {
                content()
            }
        }
    }

    private var statusSection: some View {
        HStack(spacing: 8) {
            Text("Status:")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(entry.statusCode ?? 0)")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(statusColor)
            Text("•")
                .foregroundStyle(.secondary)
            Text(entry.formattedDuration)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func headersSection(title: String, headers: [String: String]) -> some View {
        DisclosureGroup {
            ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                VStack(alignment: .leading, spacing: 2) {
                    Text(key)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.primary)
                    Text(value)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        } label: {
            Text("\(title) (\(headers.count))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private func bodySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                Text(content)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }
            .padding(8)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private var statusColor: Color {
        guard let code = entry.statusCode else { return .secondary }
        switch code {
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500..<600: return .red
        default: return .secondary
        }
    }
}
```

---

## 5. 使用方式

### 5.1 集成到 App

#### AppDelegate.swift

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    var appCoordinator: AppCoordinator!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if DEBUG
        NetworkMonitorStore.shared.start()
        #endif

        try! AppFont.registerFonts()
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
}
```

#### LTAppApp.swift

```swift
@main
struct LTAppApp: App {
    @StateObject var coordinator: AppCoordinator
    @StateObject var homeCoordinator: HomeCoordinator
    @StateObject var preHomeCoordinator: PreHomeCoordinator
    @Namespace var dripleTransition
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase

    init() {
        // ... existing init code ...
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                coordinator.rootView()

                // 添加悬浮球
                #if DEBUG
                FloatingBallView()
                #endif
            }
        }
        .environmentObject(homeCoordinator)
        .environmentObject(coordinator)
        .environmentObject(preHomeCoordinator)
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
    }
}
```

### 5.2 功能开关

```swift
// 在需要的地方可以手动控制
NetworkMonitorStore.shared.stop()    // 停止监控
NetworkMonitorStore.shared.start()   // 重新开始
NetworkMonitorStore.shared.clear()    // 清空记录
NetworkMonitorStore.shared.isExpanded // 控制面板展开状态
```

---

## 6. 已知限制与注意事项

### 6.1 URLProtocol 的局限性

1. **只捕获通过 URLSession 的请求**：使用 `URLSession` 发起的请求才能被捕获
2. **与 SSL Pinning 的关系**：由于 SSL Pinning 是在 `SessionDelegate` 中实现的，URLProtocol 捕获的是 Pinning 验证通过后的请求
3. **循环拦截风险**：转发请求时使用不包含 `NetworkMonitorURLProtocol` 的新 Session 避免循环

### 6.2 性能考虑

1. **Body 存储**：只存储前 1MB 的请求/响应 Body，避免内存占用过大
2. **记录数量限制**：最多保存 100 条记录，超过后自动清除最旧的记录
3. **仅 Debug 构建**：`#if DEBUG` 确保 Release 构建不会包含监控代码

### 6.3 与现有网络层的关系

1. **完全独立**：不修改 `ApiClient` 或任何 `NetworkInterceptor`
2. **被动监听**：只能看到请求，无法修改或阻止请求
3. **无副作用**：不影响任何业务逻辑，只是"旁观"

---

## 7. 文件清单

| 文件路径 | 说明 |
|----------|------|
| `core/Common/Source/NetworkMonitor/Model/NetworkMonitorEntry.swift` | 单个请求数据模型 |
| `core/Common/Source/NetworkMonitor/Model/NetworkMonitorConfiguration.swift` | 启动配置 |
| `core/Common/Source/NetworkMonitor/Core/NetworkMonitorURLProtocol.swift` | URLProtocol 实现 |
| `core/Common/Source/NetworkMonitor/Core/NetworkMonitorSessionManager.swift` | Session 管理器 |
| `core/Common/Source/NetworkMonitor/Store/NetworkMonitorStore.swift` | 状态管理 |
| `core/Common/Source/NetworkMonitor/UI/FloatingBallView.swift` | 悬浮球组件 |
| `core/Common/Source/NetworkMonitor/UI/NetworkMonitorPanelView.swift` | 展开面板 |
| `core/Common/Source/NetworkMonitor/UI/RequestRowView.swift` | 请求行视图 |
| `core/Common/Source/NetworkMonitor/UI/RequestDetailView.swift` | 请求详情视图 |
| `core/Common/Source/NetworkMonitor/NetworkMonitorModule.swift` | 模块入口 |

---

## 8. 依赖关系

```
core/Common/
├── Source/
│   └── NetworkMonitor/ (本模块)
│       └── 无外部依赖（仅使用 Foundation, SwiftUI）
└── Dependencies: 无新增依赖

app/LTApp/
├── LTApp/
│   └── Source/
│       └── App/
│           ├── AppDelegate.swift (修改)
│           └── LTAppApp.swift (修改)
└── Dependencies: 无变化
```

---

## 9. 测试计划

### 9.1 单元测试
- `NetworkMonitorEntry` 格式化方法测试
- `NetworkMonitorStore` 添加/删除/清空逻辑测试

### 9.2 集成测试
- 验证 URLProtocol 正确拦截请求
- 验证请求转发不会产生循环
- 验证 SwiftUI 组件正确渲染

### 9.3 手动测试
- 在 Debug 构建中验证悬浮球显示
- 触发实际 API 请求验证捕获功能
- 验证详情面板显示完整信息
- 验证清空和关闭功能
