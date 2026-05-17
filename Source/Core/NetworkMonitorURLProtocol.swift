//
//  NetworkMonitorURLProtocol.swift
//  Common
//
//  Created by LittleThings AI on 2026/05/17.
//

import Foundation

/// A passive URLProtocol that monitors all HTTP/HTTPS requests.
/// Uses ephemeral sessions internally to avoid recursion.
public class NetworkMonitorURLProtocol: URLProtocol, @unchecked Sendable, URLSessionDataDelegate {
    private var entry: NetworkMonitorEntry?
    private var session: URLSession?
    private var dataTask: URLSessionTask?
    private var responseData = Data()
    private var didReceiveResponse = false

    private static let propertyKey = "NetworkMonitorURLProtocolKey"

    public override class func canInit(with task: URLSessionTask) -> Bool {
        guard task is URLSessionDataTask else { return false }
        guard let request = task.originalRequest else { return false }
        return canInit(with: request)
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        // Skip if already processed by our protocol
        if URLProtocol.property(forKey: propertyKey, in: request) != nil {
            return false
        }

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
        guard let url = request.url else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        // Mark request as already processed to prevent loops
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: Self.propertyKey, in: mutableRequest)

        // Capture request body - check both httpBody and httpBodyStream
        let requestBody = captureRequestBody(from: request)

        let headers = extractHeaders(from: request)
        entry = NetworkMonitorEntry(
            id: UUID(),
            url: url,
            method: request.httpMethod ?? "GET",
            requestHeaders: headers,
            requestBody: requestBody,
            startTime: Date()
        )

        Task { @MainActor in
            guard let entry = self.entry else { return }
            NetworkMonitorStore.shared.recordEntry(entry)
        }

        // Use ephemeral session to prevent recursion
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: mutableRequest as URLRequest)
        dataTask?.resume()
    }

    public override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
        session?.invalidateAndCancel()
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

        didReceiveResponse = true
        let headers = extractHeaders(from: httpResponse)
        let statusCode = httpResponse.statusCode
        guard let entryId = self.entry?.id else { return }
        Task { @MainActor in
            NetworkMonitorStore.shared.updateEntry(id: entryId) { updated in
                updated.responseHeaders = headers
                updated.statusCode = statusCode
            }
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let entryId = self.entry?.id else { return }

        if let error {
            Task { @MainActor in
                NetworkMonitorStore.shared.updateEntry(id: entryId) { updated in
                    updated.error = error
                    updated.endTime = Date()
                }
            }
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let finalResponseData = self.responseData
            Task { @MainActor in
                NetworkMonitorStore.shared.updateEntry(id: entryId) { updated in
                    updated.responseBody = finalResponseData
                    updated.endTime = Date()
                }
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    // MARK: - Helpers

    private func captureRequestBody(from request: URLRequest) -> Data? {
        if let httpBody = request.httpBody {
            return httpBody
        }
        if let httpBodyStream = request.httpBodyStream {
            return readStream(httpBodyStream)
        }
        return nil
    }

    private func readStream(_ stream: InputStream) -> Data? {
        var data = Data()
        stream.open()
        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            stream.close()
            buffer.deallocate()
        }
        while stream.hasBytesAvailable {
            let bytesRead = stream.read(buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                data.append(buffer, count: bytesRead)
            } else if bytesRead < 0 {
                return nil
            }
        }
        return data
    }

    private func extractHeaders(from request: URLRequest) -> [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            headers[key] = value
        }
        return headers
    }

    private func extractHeaders(from response: HTTPURLResponse) -> [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            headers[String(describing: key)] = String(describing: value)
        }
        return headers
    }
}
