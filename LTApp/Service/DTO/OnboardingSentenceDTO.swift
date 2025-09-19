//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

struct OnboardingSentenceDTO: Decodable {
    var page1st: String
    var page2st: String
    var page3st: String
    var page4st: String
}


extension OnboardingSentenceDTO {
    func toDomain() -> OnboardingSentence {
        .init(
            page1st: page1st,
            page2st: page2st,
            page3st: page3st,
            page4st: page4st
        )
    }
}

