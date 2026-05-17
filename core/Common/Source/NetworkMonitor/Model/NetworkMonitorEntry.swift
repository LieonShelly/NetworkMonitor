//
//  NetworkMonitorEntry.swift
//  Common
//
//  Created by LittleThings AI on 2026/05/17.
//

import Foundation

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

    public var duration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    public var state: State {
        switch (statusCode, error, endTime) {
        case (_, _, nil):
            return .loading
        case (_, let err?, _):
            return .failed(err)
        case (let code?, _, _) where (200..<300).contains(code):
            return .success
        case (let code?, _, _):
            return .failed(NSError(domain: "HTTP", code: code))
        case (nil, _, _):
            return .loading
        }
    }

    public enum State: Sendable {
        case loading
        case success
        case failed(Error)
    }

    public init(
        id: UUID = UUID(),
        url: URL,
        method: String,
        requestHeaders: [String: String],
        requestBody: Data?,
        responseHeaders: [String: String]? = nil,
        responseBody: Data? = nil,
        statusCode: Int? = nil,
        error: Error? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil
    ) {
        self.id = id
        self.url = url
        self.method = method
        self.requestHeaders = requestHeaders
        self.requestBody = requestBody
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
        self.statusCode = statusCode
        self.error = error
        self.startTime = startTime
        self.endTime = endTime
    }

    public var formattedDuration: String {
        guard let duration else { return "..." }
        if duration < 1 {
            return String(format: "%.0fms", duration * 1000)
        } else {
            return String(format: "%.2fs", duration)
        }
    }

    public var requestBodyString: String? {
        guard let data = requestBody else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public var responseBodyString: String? {
        guard let data = responseBody else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public var prettyPrintedRequestBody: String? {
        guard let data = requestBody else { return nil }
        return prettyPrintJSON(data: data)
    }

    public var prettyPrintedResponseBody: String? {
        guard let data = responseBody else { return nil }
        return prettyPrintJSON(data: data)
    }

    private func prettyPrintJSON(data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8)
        }
        return prettyString
    }
}
