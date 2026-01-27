//
//  DeleteAnswerView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/21.
//

import SwiftUI
import UIComponent

struct DeleteAnswerView: View {
    @State var show: Bool = false
    @Binding var isPresented: Bool
    var deleteAction: (() -> Void)?
    
    init(isPresented: Binding<Bool>, deleteAction: (() -> Void)?) {
        self._isPresented = isPresented
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if show {
                AppColor.color(hex: 0x000000).opacity(0.25)
                    .transition(.opacity)
                    .onTapGesture {
                        show.toggle()
                    }
                
                VStack(spacing: .zero) {
                      topLine
                      deleteBtn
                      closeBtn
                  }
                  .background(
                      RoundedRectangleWithCorners(radius: 20, corners: [.topLeft, .topRight])
                          .fill(AppColor.backgroundPage)
                  )
                  .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                  .zIndex(100)
                  .onDisappear {
                      isPresented.toggle()
                  }
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut, value: show)
        .task {
            show.toggle()
        }
      
    }
    
    var topLine: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AppColor.color(hex: 0xD9D9D9))
            .frame(width: 60, height: 6)
            .padding(.top, 12)
    }
    
    var deleteBtn: some View {
        Button {
            show.toggle()
            deleteAction?()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xE75C06))
                .frame(height: 64)
                .overlay {
                    HStack(spacing: .zero) {
                        Image(.delete)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Delete")
                            .textStyle(size: 32, color: AppColor.color(hex: 0xffffff), fontFamily: .feltTipSeniorRegular)
                            .padding(.leading, 10)
                    }
                }
                .padding(.top, 32)
                .padding(.horizontal, 32)
        }
    }
    
    var closeBtn: some View {
        Button {
            show.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xEDEDEC))
                .frame(height: 64)
                .overlay {
                    HStack(spacing: .zero) {
                        Image(.xmark)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 20)

                        Text("Cancel")
                            .textStyle(size: 32, color: AppColor.color(hex: 0x00000), fontFamily: .feltTipSeniorRegular)
                            .padding(.leading, 10)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 32)
                .padding(.bottom, 45)
        }
    }
}
