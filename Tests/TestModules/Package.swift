// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "TestModules",
  products: [
    .library(name: "TestModules", targets: ["TestModules"]),
  ],
  dependencies: [
    .package(name: "sModel", path: "../../"),
    .package(name: "PetModule", path: "Tests/PetModule"),
    .package(name: "PersonModule", path: "Tests/PersonModule")
  ],
  targets: [
    .target(name: "TestModules", dependencies: ["sModel"]),
    .testTarget(name: "TestModulesTests", dependencies: ["sModel", "TestModules", "PetModule", "PersonModule"])
  ]
)
