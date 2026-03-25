//
//  LTApp, This code is protected by intellectual property rights.
//

import XCTest
@testable import LTApp
import LTNetwork

// MARK: - Mock Dependencies

final class MockRefreshTokenUseCase: RefreshTokenUseCaseType, @unchecked Sendable {
    private let lock = NSLock()
    private var _executeCallCount = 0

    var executeCallCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _executeCallCount
    }

    /// Simulated network delay in nanoseconds (default 100ms)
    var simulatedDelay: UInt64 = 100_000_000

    /// If non-nil, execute() will throw this error
    var errorToThrow: Error?

    func execute() async throws {
        lock.lock()
        _executeCallCount += 1
        lock.unlock()

        // Simulate network latency
        try await Task.sleep(nanoseconds: simulatedDelay)

        if let error = errorToThrow {
            throw error
        }
    }
}

final class MockAppDataWithoutAuthorizationService: AppDataWithoutAuthorizationServicefull {
    let refreshTokenUseCase: any RefreshTokenUseCaseType

    init(refreshTokenUseCase: any RefreshTokenUseCaseType) {
        self.refreshTokenUseCase = refreshTokenUseCase
    }
}

final class MockTokenProvider: TokenProvider {
    var accessToken: String? = "test-access-token"
    var refreshToken: String? = "test-refresh-token"

    func updateTokens(accessToken: String, refreshToken: String) throws {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
    }
}


// MARK: - RefreshTokenInterceptor Tests (migrated to onError API)

/// Tests for the migrated RefreshTokenInterceptor using the new NetworkInterceptor protocol.
/// The interceptor now only overrides `onError` instead of `adapt`/`shouldRetry`.
final class RefreshTokenInterceptorTests: XCTestCase {

    // MARK: - Helpers

    private func makeInterceptor(
        mockUseCase: MockRefreshTokenUseCase = MockRefreshTokenUseCase()
    ) -> (RefreshTokenInterceptor, MockRefreshTokenUseCase) {
        let service = MockAppDataWithoutAuthorizationService(refreshTokenUseCase: mockUseCase)
        let tokenProvider = MockTokenProvider()
        let interceptor = RefreshTokenInterceptor(tokenProvider: tokenProvider, service: service)
        return (interceptor, mockUseCase)
    }

    private func makeRequest(path: String = "/test") -> URLRequest {
        URLRequest(url: URL(string: "https://api.example.com\(path)")!)
    }

    private func make401Error() -> AppNetworkError {
        .httpError(statusCode: .unauthorized, body: nil)
    }

    // MARK: - 401 triggers retry on successful refresh

    func testOnError401WithSuccessfulRefreshReturnsRetry() async throws {
        let mockUseCase = MockRefreshTokenUseCase()
        mockUseCase.simulatedDelay = 10_000_000 // 10ms
        let (interceptor, _) = makeInterceptor(mockUseCase: mockUseCase)

        let request = makeRequest()
        let handler = ErrorInterceptorHandler()
        let result = await interceptor.onError(make401Error(), request: request, handler: handler)

        switch result {
        case .retry:
            break // expected
        case .next:
            XCTFail("Expected .retry but got .next")
        }

        XCTAssertEqual(mockUseCase.executeCallCount, 1,
                       "refreshTokenUseCase.execute() must be called exactly 1 time")
    }

    // MARK: - 401 with refresh failure returns next(error)

    func testOnError401WithRefreshFailureReturnsNext() async throws {
        let mockUseCase = MockRefreshTokenUseCase()
        mockUseCase.simulatedDelay = 10_000_000
        mockUseCase.errorToThrow = NSError(domain: "TestError", code: -1)
        let (interceptor, _) = makeInterceptor(mockUseCase: mockUseCase)

        let request = makeRequest()
        let handler = ErrorInterceptorHandler()
        let result = await interceptor.onError(make401Error(), request: request, handler: handler)

        switch result {
        case .next:
            break // expected
        case .retry:
            XCTFail("Expected .next but got .retry")
        }

        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }

    // MARK: - Non-401 errors pass through

    func testOnErrorNon401ReturnsNext() async throws {
        let (interceptor, mockUseCase) = makeInterceptor()

        let nonAuthErrors: [Error] = [
            AppNetworkError.httpError(statusCode: .notFound, body: nil),
            AppNetworkError.httpError(statusCode: .internalServerError, body: nil),
            AppNetworkError.networkError(debugDescription: "timeout", errorCode: .timedOut),
            NSError(domain: "TestError", code: -1)
        ]

        let request = makeRequest()
        let handler = ErrorInterceptorHandler()

        for error in nonAuthErrors {
            let result = await interceptor.onError(error, request: request, handler: handler)
            switch result {
            case .next:
                break // expected
            case .retry:
                XCTFail("Expected .next for non-401 error but got .retry")
            }
        }

        XCTAssertEqual(mockUseCase.executeCallCount, 0,
                       "refreshTokenUseCase.execute() must not be called for non-401 errors")
    }

    // MARK: - Concurrent 401 requests deduplicate refresh

    func testConcurrent401RequestsTriggerOnlySingleRefresh() async throws {
        let mockUseCase = MockRefreshTokenUseCase()
        mockUseCase.simulatedDelay = 200_000_000 // 200ms
        let service = MockAppDataWithoutAuthorizationService(refreshTokenUseCase: mockUseCase)
        let tokenProvider = MockTokenProvider()
        let interceptor = RefreshTokenInterceptor(tokenProvider: tokenProvider, service: service)

        let concurrentCount = 5
        let handler = ErrorInterceptorHandler()
        let error401 = make401Error()

        let results: [ErrorInterceptorResult] = await withTaskGroup(of: ErrorInterceptorResult.self) { group in
            for i in 0..<concurrentCount {
                let request = makeRequest(path: "/resource/\(i)")
                group.addTask {
                    await interceptor.onError(error401, request: request, handler: handler)
                }
            }
            var collected: [ErrorInterceptorResult] = []
            for await result in group {
                collected.append(result)
            }
            return collected
        }

        XCTAssertEqual(mockUseCase.executeCallCount, 1,
                       "Expected refreshTokenUseCase.execute() to be called exactly 1 time, "
                       + "but it was called \(mockUseCase.executeCallCount) times.")

        for result in results {
            switch result {
            case .retry:
                break // expected
            case .next:
                XCTFail("All concurrent 401 calls should return .retry after successful refresh")
            }
        }
    }
}
