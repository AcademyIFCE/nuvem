// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Nuvem",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Nuvem",
            targets: ["Nuvem"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Nuvem",
            dependencies: []
        ),
        .testTarget(
            name: "NuvemTests",
            dependencies: ["Nuvem"]
        ),
    ]
)
