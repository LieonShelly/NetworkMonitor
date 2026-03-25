//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import LTNetwork

actor RefreshTokenInterceptor: NetworkInterceptor, @unchecked Sendable {
    private weak var tokenProvider: TokenProvider?
    private let service: any AppDataWithoutAuthorizationServicefull
    private var refreshingTask: Task<Void, Error>?

    init(tokenProvider: TokenProvider?, service: any AppDataWithoutAuthorizationServicefull) {
        self.tokenProvider = tokenProvider
        self.service = service
    }

    public func onError(_ error: Error, request: URLRequest, handler: ErrorInterceptorHandler) async -> ErrorInterceptorResult {
        guard let networkError = error as? AppNetworkError,
              case .httpError(statusCode: .unauthorized, _) = networkError else {
            return handler.next(error)
        }
        do {
            try await refreshTokenIfNeeded()
            return handler.retry()
        } catch {
            return handler.next(error)
        }
    }

    private func refreshTokenIfNeeded() async throws {
        if let existingTask = refreshingTask {
            return try await existingTask.value
        }

        let task = Task {
            defer { refreshingTask = nil }
            try await service.refreshTokenUseCase.execute()
        }
        refreshingTask = task
        try await task.value
    }
}
