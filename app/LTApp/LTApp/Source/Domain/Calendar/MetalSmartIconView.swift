//
//  MetalSmartIconView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//

import SwiftUI

struct MetalSmartIconView: View {
    let originalImage: UIImage
    @State private var processedImage: UIImage?
    let thicknessLevel: Int = 2
    
    var body: some View {
        Group {
            VStack {
                VStack {
                    Text("原图")
                    Image(uiImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .border(.blue)
                        .frame(width: 40, height: 40)
                }
               
                
                if let img = processedImage {
                    VStack {
                        Text("裁剪+腐蚀处理之后：")
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                    }
                } else {
                    Color.clear
                }
            }
            .background(Color.pink)
          
        }
       
        .onAppear {
            // 使用 Metal 进行高性能裁切
            MetalImageProcessor.shared.process(originalImage, thickness: 3) { thickened in
                DispatchQueue.main.async {
                    self.processedImage = thickened
                }
            }
        }
    }
}

