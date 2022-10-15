// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "SimpleHttpClient",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16)
  ],
  products: [
    .library(name: "SimpleHttpClient", targets: ["SimpleHttpClient"])
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
    .package(url: "https://github.com/JohnSundell/Codextended", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "SimpleHttpClient",
      dependencies: [
        "Files"
      ]),
    .testTarget(
      name: "SimpleHttpClientTests",
      dependencies: [
        "SimpleHttpClient",
        "Codextended"
      ]),
  ]
)
