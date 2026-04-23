//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct PersonaOptionDTO: Decodable {
    let id: String
    let label: String
    let description: String?
}

extension PersonaOptionDTO {
    func toDomain() -> PersonaOption {
        PersonaOption(id: id, label: label, description: description)
    }
}

public struct UpdateReportPersonaDTO: Decodable {
    let reportPersonaId: String
    
    enum CodingKeys: String, CodingKey {
        case reportPersonaId = "report_persona_id"
    }
}

extension UpdateReportPersonaDTO {
    func toDomain() -> UpdateReportPersonaResult {
        UpdateReportPersonaResult(reportPersonaId: reportPersonaId)
    }
}
