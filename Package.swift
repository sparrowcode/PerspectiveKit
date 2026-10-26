// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "PerspectiveKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PerspectiveKit",
            targets: ["PerspectiveKit"]
        )
    ],
    targets: [
        .target(name: "PerspectiveKit")
    ],
    swiftLanguageModes: [.v6]
)
