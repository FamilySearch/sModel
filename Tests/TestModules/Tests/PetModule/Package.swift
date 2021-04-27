// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "PetModule",
  products: [
    .library(name: "PetModule", targets: ["PetModule"]),
  ],
  dependencies: [
    .package(name: "sModel", path: "../../../../")
  ],
  targets: [
    .target(name: "PetModule", dependencies: ["sModel"])
  ]
)
