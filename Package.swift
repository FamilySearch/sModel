// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "sModel",
    platforms: [
        .iOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "sModel",
            targets: ["sModel"])
    ],
    targets: [
        .target(
            name: "sModel",
            path: "Sources")
    ],
    swiftLanguageVersions: [.v5]
)
