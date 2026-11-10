import AppKit
import MetalKit

final class OverlayView: MTKView, MTKViewDelegate {
    private let extendedColorSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB)
    private var commandQueue: MTLCommandQueue?

    init(frame: CGRect) {
        let dev = MTLCreateSystemDefaultDevice()
        super.init(frame: frame, device: dev)
        guard let dev else { return }

        autoResizeDrawable = false
        drawableSize = CGSize(width: 1, height: 1)
        commandQueue = dev.makeCommandQueue()
        delegate = self
        colorPixelFormat = .rgba16Float
        colorspace = extendedColorSpace
        clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        // Zero CPU/GPU idle overhead: never auto-render frames in a loop
        isPaused = true
        enableSetNeedsDisplay = false

        if let metalLayer = layer as? CAMetalLayer {
            metalLayer.wantsExtendedDynamicRangeContent = true
            metalLayer.isOpaque = false
            metalLayer.pixelFormat = .rgba16Float
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func draw(in view: MTKView) {
        guard let commandQueue,
              let rpd = view.currentRenderPassDescriptor,
              let cb = commandQueue.makeCommandBuffer(),
              let encoder = cb.makeRenderCommandEncoder(descriptor: rpd),
              let drawable = view.currentDrawable else {
            return
        }
        encoder.endEncoding()
        cb.present(drawable)
        cb.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

final class OverlayWindow: NSWindow {
    private var overlay: OverlayView?

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: [],
            backing: .buffered,
            defer: false
        )
        collectionBehavior = [.stationary, .ignoresCycle, .canJoinAllSpaces]
        level = .screenSaver
        animationBehavior = .none
        canHide = false
        isOpaque = false
        hasShadow = false
        backgroundColor = .clear
        ignoresMouseEvents = true
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        alphaValue = 1.0
    }

    func install(on screen: NSScreen) {
        let view = OverlayView(frame: NSRect(origin: .zero, size: frame.size))
        view.autoresizingMask = [.width, .height]
        contentView = view
        self.overlay = view
        position(on: screen)
        orderFrontRegardless()
        view.draw() // trigger once to notify WindowServer of EDR presence
    }

    func position(on screen: NSScreen) {
        var origin = screen.frame.origin
        origin.y += screen.frame.height - 1
        setFrameOrigin(origin)
    }
}
