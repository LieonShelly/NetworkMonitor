//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

public protocol LTLogSink: Sendable {
    func log(_ event: LTLogEvent)
}
