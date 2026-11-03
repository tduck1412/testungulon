import Foundation
import MetalKit
import CoreImage
#if canImport(UIKit)
import UIKit
import SwiftUI

/// Màn hình xem trước camera thời gian thực sử dụng Metal MTKView
/// Đạt hiệu năng tối đa 60-120 fps và không tiêu tốn tài nguyên CPU.
public final class MetalCameraView: MTKView, MTKViewDelegate {

    private var currentCIImage: CIImage?
    private let commandQueue: MTLCommandQueue?
    private let ciContext: CIContext
    private let colorSpace = CGColorSpaceCreateDeviceRGB()

    public init(frame: CGRect, processor: LUTCameraProcessor) {
        self.ciContext = processor.ciContext
        self.commandQueue = processor.metalDevice.makeCommandQueue()

        super.init(frame: frame, device: processor.metalDevice)

        self.delegate = self
        self.framebufferOnly = false
        self.isPaused = false
        self.enableSetNeedsDisplay = true
        self.backgroundColor = .black

        // Kết nối luồng khung hình từ Processor sang màn hình Metal
        processor.onFrameProcessed = { [weak self] renderedImage in
            guard let self = self else { return }
            self.currentCIImage = renderedImage
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) chưa được hỗ trợ.")
    }

    // =========================================================================
    // VẼ KHUNG HÌNH LÊN METAL DRAWABLE
    // =========================================================================
    public func draw(in view: MTKView) {
        guard let image = currentCIImage,
              let currentDrawable = currentDrawable,
              let commandQueue = commandQueue,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        // Tự động căn giữa và tỉ lệ khung hình (Aspect Fill)
        let bounds = CGRect(origin: .zero, size: drawableSize)
        let scaleX = bounds.width / image.extent.width
        let scaleY = bounds.height / image.extent.height
        let scale = max(scaleX, scaleY)

        let scaledImage = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let originX = (bounds.width - scaledImage.extent.width) / 2.0
        let originY = (bounds.height - scaledImage.extent.height) / 2.0
        let centeredImage = scaledImage.transformed(by: CGAffineTransform(translationX: originX, y: originY))

        // Render trực tiếp từ CoreImage vào Metal Texture
        let destination = CIRenderDestination(
            width: Int(drawableSize.width),
            height: Int(drawableSize.height),
            pixelFormat: colorPixelFormat,
            commandBuffer: commandBuffer,
            mtlTextureProvider: { () -> MTLTexture in
                return currentDrawable.texture
            }
        )

        do {
            _ = try ciContext.startTask(toRender: centeredImage, to: destination)
            commandBuffer.present(currentDrawable)
            commandBuffer.commit()
        } catch {
            print("[Metal Camera View] Lỗi render khung hình: \(error.localizedDescription)")
        }
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

// =========================================================================
// SWIFTUI VIEW WRAPPER CHO GIAO DIỆN HIỆN ĐẠI
// =========================================================================
public struct LUTCameraPreview: UIViewRepresentable {
    public let processor: LUTCameraProcessor

    public init(processor: LUTCameraProcessor) {
        self.processor = processor
    }

    public func makeUIView(context: Context) -> MetalCameraView {
        return MetalCameraView(frame: .zero, processor: processor)
    }

    public func updateUIView(_ uiView: MetalCameraView, context: Context) {}
}
#endif
