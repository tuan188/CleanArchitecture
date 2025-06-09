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
        .package(url: "https://github.com/CoderMJLee/MJRefresh.git", from: "3.7.9")
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
                .product(name: "MJRefresh", package: "MJRefresh")
            ],
            path: "PagingTableView/Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
