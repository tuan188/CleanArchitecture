// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleanArchitecture",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "CleanArchitecture",
            targets: ["CleanArchitecture"]),
    ],
    targets: [
        .target(
            name: "CleanArchitecture",
            path: "CleanArchitecture/Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
