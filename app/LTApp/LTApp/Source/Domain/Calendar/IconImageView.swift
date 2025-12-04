//
//  IconImageView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/4.
//

import SwiftUI
import Kingfisher


struct IconImageView: View {
    let url: String
    
    var body: some View {
        KFImage(source: imageResource.map { .network($0) })
            .setProcessor(MetalIconProcessor(thickness: 4))
            .serialize(by: FormatIndicatedCacheSerializer.png)
            .cacheMemoryOnly(false)
            .resizable()
            .placeholder { _ in
                
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
    
    var imageResource: KF.ImageResource? {
        guard let url = URL(string: url) else { return nil }
        let key = iconId()
        return KF.ImageResource(downloadURL: url, cacheKey: key)
    }
    
    func iconId() -> String {
        guard let url = URL(string: url) else { return url }
        let filename = url.lastPathComponent
        if let iconId = filename.components(separatedBy: "-").first {
            return iconId
        }
        return filename
    }
}
