//
//  UserRowItem.swift
//  LTApp
//
//  Created by Renjun Li on 2025/10/30.
//

import Foundation
import SwiftUI

struct UserRowItem: Identifiable {
    let id: UUID = UUID()
    let icon: Image
    let title: String
    let subTitle: String
}


