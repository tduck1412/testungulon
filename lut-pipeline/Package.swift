// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LUTPipeline",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LUTPipeline",
            targets: ["LUTPipeline"]
        ),
    ],
    targets: [
        .target(
            name: "LUTPipeline",
            dependencies: []
        ),
        .testTarget(
            name: "LUTPipelineTests",
            dependencies: ["LUTPipeline"]
        ),
    ]
)
