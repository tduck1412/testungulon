import Foundation
import AVFoundation
import CoreImage
import Metal
import MetalKit

/// Bộ điều khiển luồng Camera thời gian thực áp dụng bảng màu 3D LUT qua GPU Metal.
/// Đảm bảo tốc độ 60 khung hình/giây không giật lag và không làm nóng CPU.
public final class LUTCameraProcessor: NSObject, ObservableObject {

    // Trạng thái phần cứng Camera
    public let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.lutpipeline.camera.session")
    private let processingQueue = DispatchQueue(label: "com.lutpipeline.camera.processing", qos: .userInteractive)

    // Metal & CoreImage Context
    public let metalDevice: MTLDevice
    public let ciContext: CIContext
    private let colorSpace = CGColorSpaceCreateDeviceRGB()

    // Bộ lọc màu hiện hành (Thread-safe)
    private var activeFilterLock = os_unfair_lock()
    private var activeLUTFilter: CIFilter?

    // Callback trả về khung hình đã được tô màu điện ảnh
    public var onFrameProcessed: ((CIImage) -> Void)?

    // Tên bộ lọc đang hiển thị
    @Published public private(set) var currentFilterName: String = "Gốc (Không màu)"

    public override init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Thiết bị không hỗ trợ Metal GPU.")
        }
        self.metalDevice = device
        // Sử dụng Metal Command Queue để tăng tối đa hiệu năng render GPU
        self.ciContext = CIContext(mtlDevice: device, options: [
            .workingColorSpace: colorSpace,
            .cacheIntermediates: false
        ])
        super.init()
    }

    // =========================================================================
    // 1. THIẾT LẬP CAMERA CAPTURE SESSION
    // =========================================================================
    public func setupCamera(position: AVCaptureDevice.Position = .back) throws {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high

            // 1. Tìm cảm biến camera góc rộng
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                self.captureSession.commitConfiguration()
                return
            }

            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }

            // 2. Thiết lập đầu ra Video Data Output (định dạng BGRA để GPU xử lý nhanh nhất)
            self.videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.setSampleBufferDelegate(self, queue: self.processingQueue)

            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }

            // 3. Khóa hướng khung hình theo chiều dọc (Portrait)
            if let connection = self.videoOutput.connection(with: .video), connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }

            self.captureSession.commitConfiguration()
        }
    }

    public func startCapture() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    public func stopCapture() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    // =========================================================================
    // 2. CHUYỂN ĐỔI BẢNG MÀU THỜI GIAN THỰC (HOT-SWAP LUT FILTER)
    // =========================================================================
    /// Gán bộ lọc 3D LUT từ đối tượng LUT3DData (đọc từ file .cube hoặc từ Presets)
    public func setLUT(_ lut: CubeLUTParser.LUT3DData?) {
        os_unfair_lock_lock(&activeFilterLock)
        defer { os_unfair_lock_unlock(&activeFilterLock) }

        if let lut = lut {
            self.activeLUTFilter = lut.createFilter(colorSpace: colorSpace)
            DispatchQueue.main.async {
                self.currentFilterName = lut.title ?? "Tùy biến (\(lut.dimension)^3)"
            }
        } else {
            self.activeLUTFilter = nil
            DispatchQueue.main.async {
                self.currentFilterName = "Gốc (Không màu)"
            }
        }
    }

    /// Đọc trực tiếp từ chuỗi tệp .cube và gán làm màu hiện hành
    public func setLUT(fromCubeString cubeString: String) throws {
        let lutData = try CubeLUTParser.parse(cubeString: cubeString)
        setLUT(lutData)
    }
}

// =========================================================================
// 3. XỬ LÝ KHUNG HÌNH (AVCaptureVideoDataOutputSampleBufferDelegate)
// =========================================================================
extension LUTCameraProcessor: AVCaptureVideoDataOutputSampleBufferDelegate {

    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        // Tạo CIImage từ bộ đệm điểm ảnh camera
        var image = CIImage(cvPixelBuffer: pixelBuffer)

        // Áp dụng bộ lọc 3D LUT nếu đang được kích hoạt
        os_unfair_lock_lock(&activeFilterLock)
        let filter = self.activeLUTFilter
        os_unfair_lock_unlock(&activeFilterLock)

        if let filter = filter {
            filter.setValue(image, forKey: kCIInputImageKey)
            if let outputImage = filter.outputImage {
                image = outputImage
            }
        }

        // Chuyển khung hình đã tô màu sang UI render
        onFrameProcessed?(image)
    }
}
