//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct PersonaOption: Sendable, Identifiable {
    public let id: String
    let label: String
    let description: String?
}

public struct UpdateReportPersonaResult: Sendable {
    let reportPersonaId: String
}
