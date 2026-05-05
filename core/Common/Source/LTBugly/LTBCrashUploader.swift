//
//  LTBCrashUploader.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Foundation

public protocol LTBCrashUploading: Sendable {
    func uploadCrashReport(_ data: Data, completion: @escaping @Sendable (Bool) -> Void)
}

public final class LTURLSessionCrashUploader: LTBCrashUploading, @unchecked Sendable {
    private let endpointURL: URL
    private let headers: [String: String]
    private let session: URLSession
    private let configuration: LTBCrashUploadConfiguration
    private let retryQueue = DispatchQueue(label: "com.littlethings.ltbugly.upload-retry")
    private let rateLimiter: LTLogRateLimiter

    public init(
        endpointURL: URL,
        headers: [String: String] = [:],
        configuration: LTBCrashUploadConfiguration = .init(),
        session: URLSession? = nil
    ) {
        self.endpointURL = endpointURL
        self.headers = headers
        self.configuration = configuration
        self.rateLimiter = LTLogRateLimiter(policy: configuration.rateLimitPolicy)

        if let session {
            self.session = session
        } else {
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.waitsForConnectivity = configuration.waitsForConnectivity
            sessionConfiguration.allowsCellularAccess = configuration.allowsCellularAccess
            sessionConfiguration.allowsExpensiveNetworkAccess = configuration.allowsExpensiveNetworkAccess
            sessionConfiguration.allowsConstrainedNetworkAccess = configuration.allowsConstrainedNetworkAccess
            self.session = URLSession(configuration: sessionConfiguration)
        }
    }

    public func uploadCrashReport(_ data: Data, completion: @escaping @Sendable (Bool) -> Void) {
        guard rateLimiter.allow(Date()) else {
            completion(false)
            return
        }

        let payload: (data: Data, contentEncoding: String?) = {
            guard configuration.enablesCompression,
                  let compressed = try? (data as NSData).compressed(using: .zlib) as Data
            else {
                return (data, nil)
            }
            return (compressed, "deflate")
        }()

        attemptUpload(
            payloadData: payload.data,
            contentEncoding: payload.contentEncoding,
            attempt: 0,
            completion: completion
        )
    }

    private func attemptUpload(
        payloadData: Data,
        contentEncoding: String?,
        attempt: Int,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let contentEncoding {
            request.setValue(contentEncoding, forHTTPHeaderField: "Content-Encoding")
        }
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = payloadData

        session.dataTask(with: request) { [configuration, retryQueue] _, response, error in
            let success = error == nil &&
                (response as? HTTPURLResponse).map { (200 ..< 300).contains($0.statusCode) } == true

            guard success == false else {
                completion(true)
                return
            }

            guard attempt < configuration.maximumRetryCount else {
                completion(false)
                return
            }

            let delay = configuration.retryBaseDelay * pow(2, Double(attempt))
            retryQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.attemptUpload(
                    payloadData: payloadData,
                    contentEncoding: contentEncoding,
                    attempt: attempt + 1,
                    completion: completion
                )
            }
        }.resume()
    }
}
