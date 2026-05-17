//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Combine

public final class CancellableBox: @unchecked Sendable {
    public var value: AnyCancellable?
    
    public init(value: AnyCancellable? = nil) {
        self.value = value
    }
    
    public func cancel() {
        value?.cancel()
    }
}
