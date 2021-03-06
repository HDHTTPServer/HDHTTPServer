// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HDHTTPServer",
    products: [
        .executable(
            name: "HDHTTPServerRun",
            targets: ["HDHTTPServerRun"]),
        .library(
            name: "HDHTTPServer",
            targets: ["HDHTTPServer"]),
    ],
    dependencies: [
         .package(url: "git@github.com:IBM-Swift/BlueSignals.git", from: "0.9.50"),
    ],
    targets: [
        .target(
            name: "HDHTTPServer",
            dependencies: ["Signals"]),
        .target(
            name: "HDHTTPServerRun",
            dependencies: ["HDHTTPServer"]),
        .testTarget(
            name: "HDHTTPServerTests",
            dependencies: ["HDHTTPServer"]),
    ]
)
