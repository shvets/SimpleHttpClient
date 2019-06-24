// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "SimpleHttpClient",
  platforms: [
//    .macOS(.v10_12),
    .iOS(.v10),
    .tvOS(.v10)
  ],
  products: [
    .library(name: "SimpleHttpClient", targets: ["SimpleHttpClient"])
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Identity", from: "0.2.0"),
    .package(url: "https://github.com/alexruperez/Tagging", from: "0.1.0"),
    .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.0.1"),
    .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.0.0"),
    .package(url: "https://github.com/JohnSundell/Files", from: "3.1.0")
  ],
  targets: [
    .target(
      name: "SimpleHttpClient",
      dependencies: [
        "SwiftSoup",
        "RxSwift",
        "Files"
      ]),
    .testTarget(
      name: "SimpleHttpClientTests",
      dependencies: [
        "SimpleHttpClient",
        "Identity",
        "Tagging"
      ]),
  ]
)
