// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "SimpleHttpClient",
  platforms: [
      .macOS(.v10_12),
      .iOS(.v10),
      .tvOS(.v10)
  ],
  products: [
      // Products define the executables and libraries produced by a package, and make them visible to other packages.
      .library(
        name: "SimpleHttpClient",
        targets: ["SimpleHttpClient"]),
  ],
  dependencies: [
      // Dependencies declare other packages that this package depends on.
      // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/JohnSundell/Identity", from: "0.2.0"),
    .package(url: "https://github.com/alexruperez/Tagging", from: "0.1.0")
  ],
  targets: [
      // Targets are the basic building blocks of a package. A target can define a module or a test suite.
      // Targets can depend on other targets in this package, and on products in packages which this package depends on.
      .target(
        name: "SimpleHttpClient",
        dependencies: []),
      .testTarget(
        name: "SimpleHttpClientTests",
        dependencies: [
          "SimpleHttpClient",
          "Identity",
          "Tagging"
        ]),
  ]
)
