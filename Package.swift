// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcode-xlsx",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .executable(name: "xcode-xlsx", targets: ["xcode-xlsx"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/CoreXLSX.git", from: "0.9.1"),
        .package(url: "https://github.com/mtynior/ColorizeSwift.git", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: "xcode-xlsx",
            dependencies: ["CoreXLSX", "ColorizeSwift"]),
        .testTarget(
            name: "xcode-xlsxTests",
            dependencies: ["xcode-xlsx"],
            path: "Tests"),
    ]
)
