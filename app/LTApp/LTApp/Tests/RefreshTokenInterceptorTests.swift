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


// MARK: - Bug Condition Exploration Test

/// **Validates: Requirements 1.1, 1.4, 2.1, 2.4**
///
/// Property 1: Bug Condition — Concurrent 401 requests trigger multiple token refreshes.
///
/// On UNFIXED code this test is EXPECTED TO FAIL, proving the race condition exists.
/// When multiple concurrent requests receive 401, each independently calls
/// `refreshTokenIfNeeded()` instead of coalescing into a single refresh operation.
final class RefreshTokenInterceptorTests: XCTestCase {

    /// Bug condition exploration: concurrent 401 requests should trigger only ONE refresh,
    /// but on unfixed code each request independently triggers its own refresh.
    func testConcurrent401RequestsTriggerOnlySingleRefresh() async throws {
        // Arrange
        let mockUseCase = MockRefreshTokenUseCase()
        // Use a meaningful delay so concurrent calls overlap
        mockUseCase.simulatedDelay = 200_000_000 // 200ms
        let mockService = MockAppDataWithoutAuthorizationService(refreshTokenUseCase: mockUseCase)
        let mockTokenProvider = MockTokenProvider()
        let interceptor = RefreshTokenInterceptor(
            tokenProvider: mockTokenProvider,
            service: mockService
        )

        let concurrentCount = 5

        // Create distinct URLRequests and 401 responses
        let requestsAndResponses: [(URLRequest, HTTPURLResponse)] = (0..<concurrentCount).map { i in
            let url = URL(string: "https://api.example.com/resource/\(i)")!
            let request = URLRequest(url: url)
            let response = HTTPURLResponse(
                url: url,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (request, response)
        }

        // Act — fire all shouldRetry calls concurrently using TaskGroup
        var results: [Bool] = []
        results = try await withThrowingTaskGroup(of: Bool.self) { group in
            for (request, response) in requestsAndResponses {
                group.addTask {
                    try await interceptor.shouldRetry(request, response: response)
                }
            }
            var collected: [Bool] = []
            for try await result in group {
                collected.append(result)
            }
            return collected
        }

        // Assert — on correctly fixed code, refresh should be called exactly once.
        // On UNFIXED code, this assertion WILL FAIL because each concurrent
        // shouldRetry call independently invokes refreshTokenIfNeeded().
        let callCount = mockUseCase.executeCallCount
        XCTAssertEqual(
            callCount, 1,
            "Expected refreshTokenUseCase.execute() to be called exactly 1 time, "
            + "but it was called \(callCount) times. "
            + "This proves the race condition: \(concurrentCount) concurrent 401 requests "
            + "each independently triggered a token refresh."
        )

        // All shouldRetry calls should return true (refresh succeeded for all)
        XCTAssertTrue(
            results.allSatisfy { $0 },
            "All concurrent shouldRetry calls should return true after successful refresh"
        )
    }
}


// MARK: - Preservation Property Tests

/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**
///
/// Property 2: Preservation — Non-concurrent 401 scenarios behave identically.
///
/// These tests verify that the fix does NOT alter any existing behavior for:
/// - Non-401 status codes (no refresh triggered)
/// - Single 401 request (exactly one refresh, shouldRetry returns true)
/// - Request already in requestsPool (no re-trigger)
/// - Refresh failure (shouldRetry returns false)
final class RefreshTokenPreservationTests: XCTestCase {

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

    private func makeResponse(statusCode: Int, url: URL? = nil) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url ?? URL(string: "https://api.example.com/test")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    // MARK: - Property 2a: Non-401 status codes do not trigger refresh

    /// **Validates: Requirements 3.1, 3.2**
    ///
    /// For any non-401 HTTP status code (200-399, 402-599), `shouldRetry` always
    /// returns `false` and the refresh use case is never called.
    func testNon401StatusCodesDoNotTriggerRefresh() async throws {
        let statusCodes = [200, 301, 400, 403, 404, 500, 502, 503]

        for statusCode in statusCodes {
            let mockUseCase = MockRefreshTokenUseCase()
            mockUseCase.simulatedDelay = 0
            let (interceptor, _) = makeInterceptor(mockUseCase: mockUseCase)

            let request = makeRequest(path: "/status/\(statusCode)")
            let url = URL(string: "https://api.example.com/status/\(statusCode)")!
            let response = makeResponse(statusCode: statusCode, url: url)

            let result = try await interceptor.shouldRetry(request, response: response)

            XCTAssertFalse(
                result,
                "shouldRetry must return false for status code \(statusCode)"
            )
            XCTAssertEqual(
                mockUseCase.executeCallCount, 0,
                "refreshTokenUseCase.execute() must not be called for status code \(statusCode)"
            )
        }
    }

    // MARK: - Property 2b: Single 401 request triggers exactly one refresh

    /// **Validates: Requirements 3.3**
    ///
    /// For a single 401 request with no concurrency, `shouldRetry` returns `true`
    /// and the refresh use case is called exactly 1 time.
    func testSingle401RequestTriggersExactlyOneRefresh() async throws {
        let mockUseCase = MockRefreshTokenUseCase()
        mockUseCase.simulatedDelay = 10_000_000 // 10ms
        let (interceptor, _) = makeInterceptor(mockUseCase: mockUseCase)

        let request = makeRequest()
        let response = makeResponse(statusCode: 401)

        let result = try await interceptor.shouldRetry(request, response: response)

        XCTAssertTrue(
            result,
            "shouldRetry must return true for a single 401 request"
        )
        XCTAssertEqual(
            mockUseCase.executeCallCount, 1,
            "refreshTokenUseCase.execute() must be called exactly 1 time for a single 401 request"
        )
    }

    // MARK: - Property 2c: Request already in pool does not re-trigger refresh

    /// **Validates: Requirements 3.4**
    ///
    /// When a request has already been through shouldRetry once (added to requestsPool),
    /// a second 401 for the same request returns `false` without triggering another refresh.
    func testRequestAlreadyInPoolDoesNotRetriggerRefresh() async throws {
        let mockUseCase = MockRefreshTokenUseCase()
        mockUseCase.simulatedDelay = 10_000_000 // 10ms
        let (interceptor, _) = makeInterceptor(mockUseCase: mockUseCase)

        let request = makeRequest()
        let response = makeResponse(statusCode: 401)

        // First call — should succeed and add request to pool
        let firstResult = try await interceptor.shouldRetry(request, response: response)
        XCTAssertTrue(firstResult, "First shouldRetry call must return true")
        XCTAssertEqual(mockUseCase.executeCallCount, 1, "Refresh must be called once on first 401")

        // Second call with the same request — should be blocked by requestsPool
        let secondResult = try await interceptor.shouldRetry(request, response: response)
        XCTAssertFalse(
            secondResult,
            "shouldRetry must return false for a request already in requestsPool"
        )
        // Refresh should NOT have been called again
        XCTAssertEqual(
            mockUseCase.executeCallCount, 1,
            "refreshTokenUseCase.execute() must not be called again for a pooled request"
        )
    }

    // MARK: - Property 2d: Refresh failure returns false

    /// **Validates: Requirements 3.4**
    ///
    /// When the refresh operation throws an error, `shouldRetry` returns `false`.
    func testRefreshFailureReturnsFalse() async throws {
        let mockUseCase = MockRefreshTokenUseCase()
        mockUseCase.simulatedDelay = 10_000_000 // 10ms
        mockUseCase.errorToThrow = NSError(domain: "TestError", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Simulated refresh token failure"
        ])
        let (interceptor, _) = makeInterceptor(mockUseCase: mockUseCase)

        let request = makeRequest()
        let response = makeResponse(statusCode: 401)

        let result = try await interceptor.shouldRetry(request, response: response)

        XCTAssertFalse(
            result,
            "shouldRetry must return false when refresh operation throws an error"
        )
        XCTAssertEqual(
            mockUseCase.executeCallCount, 1,
            "refreshTokenUseCase.execute() must be called exactly 1 time even when it fails"
        )
    }
}
