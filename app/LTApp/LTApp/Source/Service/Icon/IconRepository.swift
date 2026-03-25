//
//  IconGeneratingStatus.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/1.
//

import Foundation
import LTNetwork

public protocol IconRepositoryType {
    
    func queryIconGeneratingStatus(_ iconId: String) -> (stream: AsyncThrowingStream<IconDto, any Error>, task: NetworkTask)
}

public class IconRepository: IconRepositoryType {
    private let apiClient: ApiClient
    
    public init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    public func queryIconGeneratingStatus(_ iconId: String) -> (stream: AsyncThrowingStream<IconDto, any Error>, task: NetworkTask) {
        return apiClient.sendSSERequest(IconRequest.generate(iconId))
    }
}
