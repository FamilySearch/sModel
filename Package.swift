// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "sModel",
  products: [
    .library(name: "sModel", targets: ["sModel"]),
  ],
  dependencies: [
    .package(name: "FMDB", url: "https://github.com/ccgus/fmdb", .upToNextMinor(from: "2.7.7"))
  ],
  targets: [
    .target(name: "sModel", dependencies: ["FMDB"]),
    .testTarget(name: "sModelTests", dependencies: ["sModel"]),
  ]
)
