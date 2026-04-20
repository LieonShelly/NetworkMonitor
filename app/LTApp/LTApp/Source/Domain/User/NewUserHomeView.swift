//
//  NewUserHomeView.swift
//  LTApp
//

import SwiftUI
import UIComponent

struct NewUserHomeView: View {
    var body: some View {
        VStack(spacing: .zero) {
            FixedHeader(title: "Self")
            ScrollView(showsIndicators: false) {
                VStack(spacing: 36) {
                    // About me
                    NewUserRow(
                        icon: Image(.userOutlet),
                        title: "About me...",
                        subtitle: "Set your display name"
                    )
                    
                    // Talk to me as
                    NewUserRow(
                        icon: Image(.personaOutlet),
                        title: "Talk to me as...",
                        subtitle: "Choose the tone of voice for your insights"
                    )
                    
                    // Inspire me with
                    NewUserRow(
                        icon: Image(.libraryOutlet),
                        title: "Inspire me with...",
                        subtitle: "Browse and pin your favorite sparks"
                    )
                    
                    // Everyday, ask me
                    NewUserRow(
                        icon: Image(.cardsOutlet),
                        title: "Everyday, ask me...",
                        subtitle: "Set up your daily sparks"
                    )
                    
                    // Whisper to me at
                    NewUserRow(
                        icon: Image(.reminder),
                        title: "Whisper to me at...",
                        subtitle: "Your daily journal reminder"
                    )
                }
                .padding(.top, 16)
            }
        }
    }
}
