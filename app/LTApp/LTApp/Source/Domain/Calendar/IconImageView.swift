//
//  IconImageView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/4.
//

import SwiftUI
import Kingfisher


struct DefaultOriginalIconImageView: View {
    let url: String
    var renderMode: Image.TemplateRenderingMode?
    
    var body: some View {
        OriginalIconView(url: url, renderMode: renderMode) {
            placeholderIcon
        }
    }
    
    var placeholderIcon: some View {
        Circle()
            .fill(Color.clear)
            .overlay(content: {
                Image(.calendarDripper)
                    .renderingMode(renderMode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
    }
}

struct ThumbnailIconImageView<Placeholder: View>: View, ImageCacheKeyType {
    let url: String
    var renderMode: Image.TemplateRenderingMode?
    @ViewBuilder let placeholder:  () -> Placeholder
    
    var body: some View {
        KFImage(source: imageResource.map { .network($0) })
            .cacheOriginalImage()
            .setProcessor(MetalIconProcessor(thickness: 2))
            .serialize(by: FormatIndicatedCacheSerializer.png)
            .renderingMode(renderMode)
            .cacheMemoryOnly(false)
            .placeholder { _ in
                placeholder()
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .id(cacheKey(url))
    }
    
    var imageResource: KF.ImageResource? {
        guard let url = URL(string: url) else { return nil }
        return KF.ImageResource(downloadURL: url, cacheKey: cacheKey(self.url))
    }
}

protocol ImageCacheKeyType {
    func cacheKey(_ url: String) -> String
}

extension ImageCacheKeyType {
    func cacheKey(_ url: String) -> String {
        guard let url = URL(string: url) else { return url }
        let filename = url.lastPathComponent
        if let iconId = filename.components(separatedBy: "-").first {
            return iconId
        }
        return filename
    }
}

struct OriginalIconView<Placeholder: View>: View, ImageCacheKeyType {
    let url: String
    var renderMode: Image.TemplateRenderingMode?
    @ViewBuilder let placeholder:  () -> Placeholder
    var onSuccess: (() -> Void)? = nil
    
    var body: some View {
        KFImage(source: imageResource.map { .network($0) })
            .renderingMode(renderMode)
            .cacheOriginalImage()
            .setProcessor(MetalIconProcessor(thickness: 0))
            .placeholder { _ in
                placeholder()
            }
            .onSuccess({ _ in
                onSuccess?()
            })
            .resizable()
            .aspectRatio(contentMode: .fit)
            .id(cacheKey(url))
    }
    
    var imageResource: KF.ImageResource? {
        guard let url = URL(string: url) else { return nil }
        return KF.ImageResource(downloadURL: url, cacheKey: cacheKey(self.url))
    }
}
