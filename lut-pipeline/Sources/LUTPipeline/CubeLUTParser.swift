import Foundation
import CoreImage

/// Bộ giải mã và xử lý tệp bảng màu 3D LUT (.cube) theo chuẩn Adobe / DaVinci Resolve.
/// Chuyển đổi dữ liệu bảng màu thành đối tượng Data chuẩn RGBA Float32 tương thích với CIColorCube.
public final class CubeLUTParser {

    public enum ParserError: LocalizedError {
        case emptyData
        case unsupported1DLUT
        case missingDimension
        case invalidDimension(Int)
        case insufficientColorData(expected: Int, actual: Int)
        case invalidColorValues(line: String)

        public var errorDescription: String? {
            switch self {
            case .emptyData:
                return "Tệp .cube rỗng hoặc không có dữ liệu."
            case .unsupported1DLUT:
                return "Hệ thống chỉ hỗ trợ 3D LUT (LUT_3D_SIZE), không hỗ trợ 1D LUT."
            case .missingDimension:
                return "Không tìm thấy định nghĩa kích thước LUT_3D_SIZE trong tệp .cube."
            case .invalidDimension(let dim):
                return "Kích thước LUT_3D_SIZE không hợp lệ: \(dim). Phải là số nguyên dương (thường là 16, 32, 64)."
            case .insufficientColorData(let expected, let actual):
                return "Dữ liệu màu không đủ: Cần \(expected) điểm màu, thực tế chỉ đọc được \(actual) điểm."
            case .invalidColorValues(let line):
                return "Dòng chứa giá trị màu không hợp lệ: \(line)"
            }
        }
    }

    /// Cấu trúc chứa dữ liệu 3D LUT đã được chuẩn hóa cho CoreImage
    public struct LUT3DData {
        public let dimension: Int
        public let data: Data
        public let title: String?

        public var totalPoints: Int {
            return dimension * dimension * dimension
        }

        public var byteCount: Int {
            return data.count
        }

        /// Tạo bộ lọc CoreImage CIColorCubeWithColorSpace sẵn sàng áp dụng lên khung hình
        public func createFilter(colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()) -> CIFilter? {
            guard let filter = CIFilter(name: "CIColorCubeWithColorSpace") else { return nil }
            filter.setValue(dimension, forKey: "inputCubeDimension")
            filter.setValue(data, forKey: "inputCubeData")
            filter.setValue(colorSpace, forKey: "inputColorSpace")
            return filter
        }
    }

    /// Giải mã nội dung chuỗi văn bản của tệp .cube
    /// - Parameter cubeString: Chuỗi văn bản chứa nội dung tệp .cube
    /// - Returns: Đối tượng LUT3DData chứa mảng byte RGBA Float32
    public static func parse(cubeString: String) throws -> LUT3DData {
        guard !cubeString.isEmpty else {
            throw ParserError.emptyData
        }

        var dimension: Int?
        var title: String?
        var floatArray: [Float] = []
        var expectedPoints: Int?

        let lines = cubeString.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // Bỏ qua dòng trống hoặc dòng chú thích bắt đầu bằng '#'
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            // Đọc tiêu đề tệp
            if trimmed.hasPrefix("TITLE") {
                let parts = trimmed.components(separatedBy: "\"")
                if parts.count >= 2 {
                    title = parts[1]
                }
                continue
            }

            // Kiểm tra 1D LUT (không được hỗ trợ)
            if trimmed.hasPrefix("LUT_1D_SIZE") {
                throw ParserError.unsupported1DLUT
            }

            // Đọc kích thước lưới 3D
            if trimmed.hasPrefix("LUT_3D_SIZE") {
                let components = trimmed.split(whereSeparator: { $0.isWhitespace })
                if components.count >= 2, let dim = Int(components[1]), dim > 1 {
                    dimension = dim
                    expectedPoints = dim * dim * dim
                    // Ước tính dung lượng trước: Mỗi điểm gồm 4 giá trị Float (R, G, B, A)
                    floatArray.reserveCapacity(expectedPoints! * 4)
                } else {
                    throw ParserError.invalidDimension(-1)
                }
                continue
            }

            // Bỏ qua các chỉ dẫn phạm vi (DOMAIN_MIN / DOMAIN_MAX)
            if trimmed.hasPrefix("DOMAIN_MIN") || trimmed.hasPrefix("DOMAIN_MAX") {
                continue
            }

            // Đọc các giá trị màu RGB
            let rgbStrings = trimmed.split(whereSeparator: { $0.isWhitespace })
            if rgbStrings.count >= 3 {
                guard let r = Float(rgbStrings[0]),
                      let g = Float(rgbStrings[1]),
                      let b = Float(rgbStrings[2]) else {
                    throw ParserError.invalidColorValues(line: trimmed)
                }

                // Apple CIColorCube yêu cầu định dạng RGBA Float32:
                // R, G, B được gán trực tiếp, Alpha luôn là 1.0 (hoàn toàn không trong suốt)
                floatArray.append(r)
                floatArray.append(g)
                floatArray.append(b)
                floatArray.append(1.0)
            }
        }

        guard let dim = dimension, let totalExpected = expectedPoints else {
            throw ParserError.missingDimension
        }

        let actualPoints = floatArray.count / 4
        guard actualPoints == totalExpected else {
            throw ParserError.insufficientColorData(expected: totalExpected, actual: actualPoints)
        }

        // Chuyển đổi mảng [Float] thành Data nhị phân
        let byteData = floatArray.withUnsafeBufferPointer { buffer in
            Data(buffer: buffer)
        }

        return LUT3DData(dimension: dim, data: byteData, title: title)
    }

    /// Giải mã trực tiếp từ tệp trong hệ thống tệp tin (File URL)
    public static func parse(fileURL: URL) throws -> LUT3DData {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        return try parse(cubeString: content)
    }
}
