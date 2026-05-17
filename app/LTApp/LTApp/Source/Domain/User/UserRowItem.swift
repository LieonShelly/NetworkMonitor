//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import SwiftUI

struct UserRowItem: Identifiable {
    let id: UUID = UUID()
    let icon: Image
    let title: String
    let subTitle: String
}
