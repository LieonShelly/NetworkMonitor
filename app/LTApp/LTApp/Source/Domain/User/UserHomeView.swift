//
//  UserHomeView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/10/30.
//

import SwiftUI

struct UserHomeView: View {
    var body: some View {
        VStack(spacing: .zero) {
            titleView
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 60,) {
                    UserRow(item: .init(icon: Image(.userOutlet), title: "Name", subTitle: "jackie"))
                    
                    UserRow(item: .init(icon: Image(.libraryOutlet), title: "Question Library", subTitle: "Pin your favourite questions to the threads"))
                    
                    UserRow(item: .init(icon: Image(.reminder), title: "Reminder", subTitle: "Personalizaed to your own rhythm"))
                }
                .padding(.top, 26)
            }
        }
    }
    
    var titleView: some View {
        HStack(spacing: .zero) {
            Text("Self")
                .textStyle(size: 32)
        }
        .padding(.leading, 24)
    }
    
}
