import Foundation
import CoreGraphics

/// Bộ sinh bảng màu điện ảnh (Algorithmic 3D LUT Presets)
/// Cho phép tạo trực tiếp các bộ lọc màu chuẩn Hollywood và Vintage mà không cần tệp ngoài.
public enum LUTPresets {

    /// Bảng màu trung tính gốc (Identity LUT - Không làm biến đổi màu)
    public static func identity(dimension: Int = 32) -> CubeLUTParser.LUT3DData {
        var floatArray = [Float]()
        floatArray.reserveCapacity(dimension * dimension * dimension * 4)

        let step = 1.0 / Float(dimension - 1)

        // Quy chuẩn duyệt màu 3D LUT: Blue ngoài cùng -> Green ở giữa -> Red trong cùng
        for bIndex in 0..<dimension {
            let b = Float(bIndex) * step
            for gIndex in 0..<dimension {
                let g = Float(gIndex) * step
                for rIndex in 0..<dimension {
                    let r = Float(rIndex) * step
                    floatArray.append(r)
                    floatArray.append(g)
                    floatArray.append(b)
                    floatArray.append(1.0)
                }
            }
        }

        let data = floatArray.withUnsafeBufferPointer { Data(buffer: $0) }
        return CubeLUTParser.LUT3DData(dimension: dimension, data: data, title: "Identity Neutral")
    }

    /// Bộ lọc màu điện ảnh Teal & Orange (Hollywood Cinematic Blockbuster)
    /// Đẩy bóng tối về màu xanh Teal/Cyan, làm ấm tone da người (Orange/Warm Highlights), tăng tương phản S-Curve.
    public static func tealAndOrange(dimension: Int = 32) -> CubeLUTParser.LUT3DData {
        var floatArray = [Float]()
        floatArray.reserveCapacity(dimension * dimension * dimension * 4)

        let step = 1.0 / Float(dimension - 1)

        for bIndex in 0..<dimension {
            let b = Float(bIndex) * step
            for gIndex in 0..<dimension {
                let g = Float(gIndex) * step
                for rIndex in 0..<dimension {
                    let r = Float(rIndex) * step

                    // Tính độ sáng tổng thể (Luminance) theo chuẩn Rec.709
                    let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b

                    // 1. Áp dụng đường cong tương phản S-Curve nhẹ
                    let rContrast = applySCurve(r)
                    let gContrast = applySCurve(g)
                    let bContrast = applySCurve(b)

                    // 2. Phân chia màu theo vùng sáng tối (Color Grading Split-Toning):
                    // - Vùng tối (Shadows): Thêm Teal (tăng Blue & Green, giảm Red)
                    // - Vùng sáng (Highlights): Thêm Orange (tăng Red & Green, giảm Blue)
                    let shadowWeight = max(0.0, 1.0 - lum * 1.5)
                    let highlightWeight = max(0.0, (lum - 0.3) * 1.4)

                    var outR = rContrast + (0.15 * highlightWeight) - (0.10 * shadowWeight)
                    var outG = gContrast + (0.05 * highlightWeight) + (0.08 * shadowWeight)
                    var outB = bContrast - (0.12 * highlightWeight) + (0.20 * shadowWeight)

                    // Bảo vệ tone da người: Nếu R > G > B, hạn chế làm ám xanh
                    if r > g && g > b {
                        let skinProtection = (r - b)
                        outR = outR * (1.0 - skinProtection * 0.3) + r * (skinProtection * 0.3)
                    }

                    floatArray.append(clamp(outR))
                    floatArray.append(clamp(outG))
                    floatArray.append(clamp(outB))
                    floatArray.append(1.0)
                }
            }
        }

        let data = floatArray.withUnsafeBufferPointer { Data(buffer: $0) }
        return CubeLUTParser.LUT3DData(dimension: dimension, data: data, title: "Teal and Orange Cinematic")
    }

    /// Bộ lọc màu Vintage Cafe (Ấm áp, hoài niệm, nâng bóng tối dạng Matte)
    public static func vintageCafe(dimension: Int = 32) -> CubeLUTParser.LUT3DData {
        var floatArray = [Float]()
        floatArray.reserveCapacity(dimension * dimension * dimension * 4)

        let step = 1.0 / Float(dimension - 1)

        for bIndex in 0..<dimension {
            let b = Float(bIndex) * step
            for gIndex in 0..<dimension {
                let g = Float(gIndex) * step
                for rIndex in 0..<dimension {
                    let r = Float(rIndex) * step

                    // 1. Nâng đen (Matte/Faded Shadows) - đặc trưng ảnh chụp phim nhựa
                    let rMatte = 0.08 + r * 0.90
                    let gMatte = 0.06 + g * 0.88
                    let bMatte = 0.05 + b * 0.80

                    // 2. Nhuộm vàng hổ phách / nâu ấm ở vùng trung tính (Midtones)
                    var outR = rMatte * 1.08
                    var outG = gMatte * 1.02
                    var outB = bMatte * 0.88

                    floatArray.append(clamp(outR))
                    floatArray.append(clamp(outG))
                    floatArray.append(clamp(outB))
                    floatArray.append(1.0)
                }
            }
        }

        let data = floatArray.withUnsafeBufferPointer { Data(buffer: $0) }
        return CubeLUTParser.LUT3DData(dimension: dimension, data: data, title: "Vintage Cafe Warm")
    }

    /// Bộ lọc màu Film Cinema Gamma 3 (Mô phỏng màu phim nhựa Kodak điện ảnh độ tương phản cao)
    public static func filmCinemaGamma3(dimension: Int = 32) -> CubeLUTParser.LUT3DData {
        var floatArray = [Float]()
        floatArray.reserveCapacity(dimension * dimension * dimension * 4)

        let step = 1.0 / Float(dimension - 1)

        for bIndex in 0..<dimension {
            let b = Float(bIndex) * step
            for gIndex in 0..<dimension {
                let g = Float(gIndex) * step
                for rIndex in 0..<dimension {
                    let r = Float(rIndex) * step

                    // Đường cong Gamma 2.4 - 3.0 cho dải tương phản phim
                    let gamma: Float = 0.85
                    let rGamma = pow(r, gamma)
                    let gGamma = pow(g, gamma)
                    let bGamma = pow(b, gamma)

                    // Giảm nhẹ độ bão hòa màu vàng/xanh gắt
                    var outR = rGamma * 1.04
                    var outG = gGamma * 0.98
                    var outB = bGamma * 1.02

                    floatArray.append(clamp(outR))
                    floatArray.append(clamp(outG))
                    floatArray.append(clamp(outB))
                    floatArray.append(1.0)
                }
            }
        }

        let data = floatArray.withUnsafeBufferPointer { Data(buffer: $0) }
        return CubeLUTParser.LUT3DData(dimension: dimension, data: data, title: "Life Cinema Gamma 3")
    }

    // =========================================================================
    // HÀM TOÁN HỌC BỔ TRỢ (UTILITIES)
    // =========================================================================
    private static func applySCurve(_ x: Float) -> Float {
        // Hàm đa thức bậc 3 tạo đường cong S mượt mà
        return x * x * (3.0 - 2.0 * x)
    }

    private static func clamp(_ value: Float, min: Float = 0.0, max: Float = 1.0) -> Float {
        if value < min { return min }
        if value > max { return max }
        return value
    }
}
