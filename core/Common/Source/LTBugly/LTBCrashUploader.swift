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

    public init(
        endpointURL: URL,
        headers: [String: String] = [:],
        session: URLSession = .shared
    ) {
        self.endpointURL = endpointURL
        self.headers = headers
        self.session = session
    }

    public func uploadCrashReport(_ data: Data, completion: @escaping @Sendable (Bool) -> Void) {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = data

        session.dataTask(with: request) { _, response, error in
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  (200 ..< 300).contains(httpResponse.statusCode)
            else {
                completion(false)
                return
            }

            completion(true)
        }.resume()
    }
}

