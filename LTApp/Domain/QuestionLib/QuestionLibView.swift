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
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 36)
            
            VStack(spacing: .zero) {
                sectionHeader("Simple Joys")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
                row("What is one little thing that made you happy today?")
            }
            .padding(.horizontal, 40)
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
    
    func row(_ text: String) -> some View {
        VStack(spacing: .zero) {
            HStack {
                Text(text)
                    .textStyle(size: 14, fontFamily: .poppinsRegular)
                Spacer()
            }
            .padding(.vertical, 12)
            
            Rectangle()
                .fill(AppColor.color(hex: 0xCDCDCD))
                .frame(height: 0.5)
        }
    }
}
