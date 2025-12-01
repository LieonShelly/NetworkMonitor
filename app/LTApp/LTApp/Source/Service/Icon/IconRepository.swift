//
//  IconGeneratingStatus.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/1.
//

import Foundation
import LTNetwork

public protocol IconRepositoryType {
    
    func queryIconGeneratingStatus(_ iconId: String) -> AsyncThrowingStream<IconData, any Error>
}

public class IconRepository: IconRepositoryType {
    
    public func queryIconGeneratingStatus(_ iconId: String) -> AsyncThrowingStream<IconData, any Error> {
        AsyncThrowingStream<IconData, any Error> { continuation in
            let task = Task.detached {
                let request = IconRequest.generate(iconId)
                let builder = RequestBuilder(request: request)
                var urlRequest = builder.build(.dev)
                urlRequest.timeoutInterval = 300
                urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                do {
                    let bytes = try await URLSession.shared.bytes(for: urlRequest)
                    guard let httpResonse = bytes.1 as? HTTPURLResponse, httpResonse.statusCode == 200 else {
                        continuation.finish(throwing: URLError(.badServerResponse))
                        return
                    }
                    for try await line in bytes.0.lines {
                        if line.hasPrefix("data:") {
                            let jsonString = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                            if let data = jsonString.data(using: .utf8) {
                                let reponse: UniversalResponse<IconDto> = try JSONDecoder().decode(UniversalResponse<IconDto> .self, from: data)
                                continuation.yield(reponse.data.toDomain())
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
