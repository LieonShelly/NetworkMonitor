//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct QuestionLibView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    var body: some View {
        ScrollView {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 36)
            
            VStack(spacing: .zero) {
                sectionHeader("Simple Joys")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
            }
            .padding(.bottom, 36)
            
            VStack(spacing: .zero) {
                sectionHeader("Simple Joys")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
                QestionRow(text: "What is one little thing that made you happy today?")
            }
            .padding(.bottom, 36)
        }
        .defaultBackground()
        .defaultNavigationBar("Question Library") {
            homeCoordinator.pop()
        }
    }
    
    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .textStyle(size: 24)
            Spacer()
        }
        .padding(.leading, 3)
    }
}
