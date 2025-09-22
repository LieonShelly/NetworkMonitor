//
//  LTApp, This code is protected by intellectual property rights.
//


import Foundation

struct CategoryDTO: Decodable {
    var id: String
    var name: String
}

extension CategoryDTO {
    func toDomain() -> Category {
        return Category(id: id, name: name)
    }
}
