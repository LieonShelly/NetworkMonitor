//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

public protocol LTRemoteLogTransport: Sendable {
    func send(_ events: [LTLogEvent], completion: @escaping @Sendable (Bool) -> Void)
}

public struct LTRemoteLogConfiguration: Sendable, Equatable {
    public let minimumLevel: LTLogLevel
    public let batchSize: Int
    public let flushInterval: TimeInterval
    public let maximumBufferSize: Int
    public let sendsExportableEventsOnly: Bool
    public let samplingPolicy: LTLogSamplingPolicy
    public let rateLimitPolicy: LTLogRateLimitPolicy

    public init(
        minimumLevel: LTLogLevel = .warning,
        batchSize: Int = 20,
        flushInterval: TimeInterval = 15,
        maximumBufferSize: Int = 200,
        sendsExportableEventsOnly: Bool = true,
        samplingPolicy: LTLogSamplingPolicy = .always,
        rateLimitPolicy: LTLogRateLimitPolicy = .disabled
    ) {
        self.minimumLevel = minimumLevel
        self.batchSize = max(1, batchSize)
        self.flushInterval = max(1, flushInterval)
        self.maximumBufferSize = max(1, maximumBufferSize)
        self.sendsExportableEventsOnly = sendsExportableEventsOnly
        self.samplingPolicy = samplingPolicy
        self.rateLimitPolicy = rateLimitPolicy
    }
}

public final class LTRemoteLogSink: LTLogSink, @unchecked Sendable {
    public let configuration: LTRemoteLogConfiguration

    private let transport: any LTRemoteLogTransport
    private let queue = DispatchQueue(label: "com.littlethings.ltlog.remote-sink")
    private let timer: DispatchSourceTimer
    private let rateLimiter: LTLogRateLimiter
    private var buffer: [LTLogEvent] = []

    public init(
        configuration: LTRemoteLogConfiguration = .init(),
        transport: any LTRemoteLogTransport
    ) {
        self.configuration = configuration
        self.transport = transport
        self.rateLimiter = LTLogRateLimiter(policy: configuration.rateLimitPolicy)
        self.timer = DispatchSource.makeTimerSource(queue: queue)

        timer.schedule(
            deadline: .now() + configuration.flushInterval,
            repeating: configuration.flushInterval
        )
        timer.setEventHandler { [weak self] in
            self?.flushOnQueue()
        }
        timer.resume()
    }

    deinit {
        timer.cancel()
    }

    public func log(_ event: LTLogEvent) {
        guard event.level >= configuration.minimumLevel,
              configuration.samplingPolicy.shouldRecord(level: event.level),
              rateLimiter.allow(event.timestamp),
              configuration.sendsExportableEventsOnly == false || event.message != nil
        else {
            return
        }

        queue.async { [weak self] in
            guard let self else { return }
            buffer.append(event)
            trimBufferIfNeeded()

            if buffer.count >= configuration.batchSize {
                flushOnQueue()
            }
        }
    }

    public func flush() {
        queue.async { [weak self] in
            self?.flushOnQueue()
        }
    }

    public func flushAndWait() {
        queue.sync {
            flushOnQueue()
        }
    }

    private func flushOnQueue() {
        guard buffer.isEmpty == false else {
            return
        }

        let batch = Array(buffer.prefix(configuration.batchSize))
        buffer.removeFirst(batch.count)

        transport.send(batch) { [weak self] success in
            guard success == false else { return }

            self?.queue.async { [weak self] in
                guard let self else { return }
                buffer.insert(contentsOf: batch, at: 0)
                trimBufferIfNeeded()
            }
        }
    }

    private func trimBufferIfNeeded() {
        guard buffer.count > configuration.maximumBufferSize else {
            return
        }

        buffer.removeFirst(buffer.count - configuration.maximumBufferSize)
    }
}

public final class LTURLSessionRemoteLogTransport: LTRemoteLogTransport, @unchecked Sendable {
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

    public func send(_ events: [LTLogEvent], completion: @escaping @Sendable (Bool) -> Void) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            var request = URLRequest(url: endpointURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            headers.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
            request.httpBody = try encoder.encode(events)

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
        } catch {
            completion(false)
        }
    }
}
