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
         .package(url: "git@github.com:swift-server/http.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "HDHTTPServer",
            dependencies: ["Signals"]),
        .target(
            name: "HDHTTPServerRun",
            dependencies: ["HDHTTPServer", "HTTP"]),
        .testTarget(
            name: "HDHTTPServerTests",
            dependencies: ["HDHTTPServer"]),
    ]
)
