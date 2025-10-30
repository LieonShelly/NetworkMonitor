//
//  InsightsView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/10/30.
//

import SwiftUI

struct InsightsView: View {
    var body: some View {
        VStack(spacing: .zero) {
            titleView
            ScrollView(showsIndicators: false) {
            }
        }
    }
    
    var titleView: some View {
        HStack(spacing: .zero) {
            Text("AI Insights")
                .textStyle(size: 33)
        }
        .padding(.leading, 24)
    }
}


