//
//  MTKViewRepresentable.swift
//  LTApp
//

import SwiftUI
import MetalKit

struct MTKViewRepresentable: UIViewRepresentable {
    let renderer: ColorOverlayRenderer

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.colorPixelFormat = .rgba8Unorm
        mtkView.isPaused = true
        mtkView.enableSetNeedsDisplay = true
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 1, blue: 0, alpha: 0)
        mtkView.isOpaque = false
        mtkView.delegate = context.coordinator
        renderer.mtkView = mtkView
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {}

    static func dismantleUIView(_ uiView: MTKView, coordinator: Coordinator) {
        uiView.delegate = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(renderer: renderer)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        let renderer: ColorOverlayRenderer

        init(renderer: ColorOverlayRenderer) {
            self.renderer = renderer
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            renderer.renderToView()
        }
    }
}
