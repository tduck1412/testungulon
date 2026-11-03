import XCTest
import CoreImage
@testable import LUTPipeline

final class CubeLUTParserTests: XCTestCase {

    // =========================================================================
    // TEST 1: GIẢI MÃ TỆP .CUBE 2x2x2 ĐƠN GIẢN
    // =========================================================================
    func test01_parseSimple2x2x2CubeString() throws {
        let sampleCube = """
        # Bảng màu kiểm thử 2x2x2
        TITLE "Test Mini Cube"
        LUT_3D_SIZE 2
        DOMAIN_MIN 0.0 0.0 0.0
        DOMAIN_MAX 1.0 1.0 1.0

        0.0 0.0 0.0
        1.0 0.0 0.0
        0.0 1.0 0.0
        1.0 1.0 0.0
        0.0 0.0 1.0
        1.0 0.0 1.0
        0.0 1.0 1.0
        1.0 1.0 1.0
        """

        let result = try CubeLUTParser.parse(cubeString: sampleCube)

        XCTAssertEqual(result.dimension, 2)
        XCTAssertEqual(result.title, "Test Mini Cube")
        XCTAssertEqual(result.totalPoints, 8) // 2 * 2 * 2 = 8 điểm

        // 8 điểm * 4 thành phần (RGBA) * 4 bytes/Float = 128 bytes
        let expectedBytes = 8 * 4 * MemoryLayout<Float>.size
        XCTAssertEqual(result.byteCount, expectedBytes)

        // Kiểm tra tạo bộ lọc CIFilter thành công
        let filter = result.createFilter()
        XCTAssertNotNil(filter, "Phải tạo được CIFilter CIColorCubeWithColorSpace hợp lệ")
        XCTAssertEqual(filter?.value(forKey: "inputCubeDimension") as? Int, 2)
    }

    // =========================================================================
    // TEST 2: KIỂM THỬ BẢNG MÀU THUẬT TOÁN TEAL & ORANGE (32x32x32)
    // =========================================================================
    func test02_tealAndOrangePresetGeneration() {
        let lut = LUTPresets.tealAndOrange(dimension: 32)

        XCTAssertEqual(lut.dimension, 32)
        XCTAssertEqual(lut.totalPoints, 32 * 32 * 32) // 32.768 điểm màu

        // 32.768 * 4 * 4 = 524.288 bytes (512 KB)
        let expectedBytes = 32 * 32 * 32 * 4 * MemoryLayout<Float>.size
        XCTAssertEqual(lut.byteCount, expectedBytes)

        // Kiểm tra các giá trị trong buffer: Tất cả phải nằm trong [0.0, 1.0] và Alpha = 1.0
        lut.data.withUnsafeBytes { rawBuffer in
            let floatBuffer = rawBuffer.bindMemory(to: Float.self)
            for i in stride(from: 0, to: floatBuffer.count, by: 4) {
                let r = floatBuffer[i]
                let g = floatBuffer[i + 1]
                let b = floatBuffer[i + 2]
                let a = floatBuffer[i + 3]

                XCTAssertGreaterThanOrEqual(r, 0.0)
                XCTAssertLessThanOrEqual(r, 1.0)
                XCTAssertGreaterThanOrEqual(g, 0.0)
                XCTAssertLessThanOrEqual(g, 1.0)
                XCTAssertGreaterThanOrEqual(b, 0.0)
                XCTAssertLessThanOrEqual(b, 1.0)
                XCTAssertEqual(a, 1.0, "Thành phần Alpha phải luôn là 1.0")
            }
        }
    }

    // =========================================================================
    // TEST 3: KIỂM THỬ CÁC PRESETS VINTAGE CAFE & FILM CINEMA GAMMA 3
    // =========================================================================
    func test03_otherPresetsGeneration() {
        let cafeLUT = LUTPresets.vintageCafe(dimension: 16)
        XCTAssertEqual(cafeLUT.dimension, 16)
        XCTAssertEqual(cafeLUT.byteCount, 16 * 16 * 16 * 4 * MemoryLayout<Float>.size)
        XCTAssertNotNil(cafeLUT.createFilter())

        let cinemaLUT = LUTPresets.filmCinemaGamma3(dimension: 32)
        XCTAssertEqual(cinemaLUT.dimension, 32)
        XCTAssertEqual(cinemaLUT.byteCount, 32 * 32 * 32 * 4 * MemoryLayout<Float>.size)
        XCTAssertNotNil(cinemaLUT.createFilter())
    }

    // =========================================================================
    // TEST 4: BẮT LỖI KHI DỮ LIỆU .CUBE BỊ SAI LỆCH HOẶC THIẾU DÒNG
    // =========================================================================
    func test04_errorHandlingOnCorruptedCube() {
        // Thiếu định nghĩa LUT_3D_SIZE
        let missingDimCube = """
        0.0 0.0 0.0
        1.0 1.0 1.0
        """
        XCTAssertThrowsError(try CubeLUTParser.parse(cubeString: missingDimCube))

        // Dữ liệu màu bị thiếu (khai báo size 2 nhưng chỉ có 3 điểm thay vì 8)
        let incompleteCube = """
        LUT_3D_SIZE 2
        0.0 0.0 0.0
        0.5 0.5 0.5
        1.0 1.0 1.0
        """
        XCTAssertThrowsError(try CubeLUTParser.parse(cubeString: incompleteCube))

        // Báo lỗi nếu là 1D LUT
        let oneDCube = """
        LUT_1D_SIZE 256
        0.0 0.0 0.0
        """
        XCTAssertThrowsError(try CubeLUTParser.parse(cubeString: oneDCube))
    }
}
