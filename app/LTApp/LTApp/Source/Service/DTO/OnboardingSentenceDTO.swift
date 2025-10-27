//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

struct OnboardingSentenceDTO: Decodable {
    var page1st: String
    var page2nd: String
    var page3rd: String
    var page4th: String
}


extension OnboardingSentenceDTO {
    func toDomain() -> OnboardingSentence {
        .init(
            page1st: page1st,
            page2st: page2nd,
            page3st: page3rd,
            page4st: page4th
        )
    }
}

