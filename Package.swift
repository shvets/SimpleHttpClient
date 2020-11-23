// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "SimpleHttpClient",
  platforms: [
    .macOS(.v10_12),
    .iOS(.v12),
    .tvOS(.v12)
  ],
  products: [
    .library(name: "SimpleHttpClient", targets: ["SimpleHttpClient"])
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Files", from: "4.1.1"),
    .package(url: "https://github.com/shvets/Await", from: "1.0.0"),
    .package(url: "https://github.com/JohnSundell/Codextended", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "SimpleHttpClient",
      dependencies: [
        "Files",
        "Await"
      ]),
    .testTarget(
      name: "SimpleHttpClientTests",
      dependencies: [
        "SimpleHttpClient",
        "Await",
        "Codextended"
      ]),
  ]
)
