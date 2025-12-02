//
//  AnswerDetailView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/2.
//


import SwiftUI
import UIComponent
import Kingfisher

struct AnswerDetailView: View {
    let answer: Answer
    
    var body: some View {
        VStack {
            if let url = answer.icon?.url {
                KFImage(URL(string: url))
                    .resizable()
                    .placeholder { _ in
                        LoadingView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 50)
            }
        }
        .defaultBackground()
       
    }
}
