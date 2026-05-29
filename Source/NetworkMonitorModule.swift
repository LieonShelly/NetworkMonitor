//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import SwiftUI

@MainActor
public enum NetworkMonitorModule {
    /// Starts the network monitor.
    /// Call this early in app lifecycle to capture most requests.
    public static func start() {
        NetworkMonitorStore.shared.start()
    }

    /// Stops the network monitor.
    public static func stop() {
        NetworkMonitorStore.shared.stop()
    }

    /// Clears all captured entries.
    public static func clear() {
        NetworkMonitorStore.shared.clear()
    }

    /// The floating ball view for displaying network monitor UI.
    @ViewBuilder
    public static var floatingBall: some View {
        FloatingBallView()
    }
}
