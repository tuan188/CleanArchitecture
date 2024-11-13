// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleanArchitecture",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CleanArchitecture",
            targets: ["CleanArchitecture"]),
        .library(
            name: "PagingTableView",
            targets: ["PagingTableView"])
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.4.1"),
        .package(url: "https://github.com/eggswift/pull-to-refresh.git", from: "2.9.3")
    ],
    targets: [
        .target(
            name: "CleanArchitecture",
            path: "CleanArchitecture/Sources"
        ),
        .target(
            name: "PagingTableView",
            dependencies: [
                "CleanArchitecture",
                .product(name: "CombineCocoa", package: "CombineCocoa"),
                .product(name: "ESPullToRefresh", package: "pull-to-refresh")
            ],
            path: "PagingTableView/Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
