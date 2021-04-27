// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "PersonModule",
  products: [
    .library(name: "PersonModule", targets: ["PersonModule"]),
  ],
  dependencies: [
    .package(name: "sModel", path: "../../../../")
  ],
  targets: [
    .target(name: "PersonModule", dependencies: ["sModel"])
  ]
)
