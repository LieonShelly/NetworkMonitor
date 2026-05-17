//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Combine
import Foundation
import LTNetwork

public protocol QueryIconGeneratingStatusUseCaseType: Sendable {
    func execute(_ iconId: String) -> AsyncThrowingStream<IconDto, any Error>
    
    func statusStream(for iconId: String) -> AsyncStream<IconDto>
    
    func startMonitoring(_ iconId: String)
    
    func stopMonitoring(_ iconId: String)
}

public final class QueryIconGeneratingStatusUseCase: QueryIconGeneratingStatusUseCaseType, @unchecked Sendable {
    private let repository: any IconRepositoryType
    
    public init(repository: any IconRepositoryType) {
        self.repository = repository
    }
    private var stateCache: [String: IconDto] = [:]
    private let eventSubject = PassthroughSubject<IconDto, Never>()
    private var activeTasks: [String: Task<Void, Never>] = [:]
    
    
    public func execute(_ iconId: String) -> AsyncThrowingStream<IconDto, any Error> {
        repository.queryIconGeneratingStatus(iconId).stream
    }
    
    
    public func statusStream(for iconId: String) -> AsyncStream<IconDto> {
        let currentCachedValue = stateCache[iconId]
        return AsyncStream { continuation in
            if let cached = currentCachedValue {
                continuation.yield(cached)
            }
            let box = CancellableBox()
            box.value = eventSubject
                .filter { $0.id == iconId }
                .map { $0 }
                .sink { dto in
                    continuation.yield(dto)
                }
            continuation.onTermination = { _ in
                box.cancel()
            }
        }
    }
    
    public func startMonitoring(_ iconId: String) {
        if activeTasks[iconId] != nil {
            return
        }
        let task = Task { [weak self] in
            guard let self else { return}
            defer {
                self.activeTasks.removeValue(forKey: iconId)
            }
            do {
                let (stream, _) = self.repository.queryIconGeneratingStatus(iconId)
                for try await status in stream {
                    self.stateCache[iconId] = status
                    self.eventSubject.send(status)
                    if status.status == .generated || status.status == .failed {
                        break
                    }
                }
            } catch {
                
            }
        }
        activeTasks[iconId] = task
    }
    
    public func stopMonitoring(_ iconId: String) {
        activeTasks[iconId]?.cancel()
        activeTasks.removeValue(forKey: iconId)
    }
}
