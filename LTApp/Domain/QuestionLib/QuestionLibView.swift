//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct QuestionLibView: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    var body: some View {
        Text("Question Library")
            .defaultBackground()
            .defaultNavigationBar("Question Library") {
                homeCoordinator.pop()
            }
    }
}
