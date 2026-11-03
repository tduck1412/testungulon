// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StoreKitSandbox",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "StoreKitSandbox",
            targets: ["StoreKitSandbox"]
        ),
    ],
    targets: [
        .target(
            name: "StoreKitSandbox",
            dependencies: []
        ),
        .testTarget(
            name: "StoreKitSandboxTests",
            dependencies: ["StoreKitSandbox"],
            resources: [
                .copy("../../Products.storekit")
            ]
        ),
    ]
)
