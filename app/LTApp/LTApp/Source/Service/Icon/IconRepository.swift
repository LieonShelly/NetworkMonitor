//
//  IconGeneratingStatus.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/1.
//

import Foundation
import LTNetwork

public protocol IconRepositoryType {
    
    func queryIconGeneratingStatus(_ iconId: String) -> AsyncThrowingStream<IconDto, any Error>
}

public class IconRepository: IconRepositoryType {
    private let apiClient: ApiClient
    
    public init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    public func queryIconGeneratingStatus(_ iconId: String) -> AsyncThrowingStream<IconDto, any Error> {
        let reponse: AsyncThrowingStream<IconDto, any Error> = apiClient.sendSSERequest(IconRequest.generate(iconId))
        return reponse
    }
}
