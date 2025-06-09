// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PagingTableView",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PagingTableView",
            targets: ["PagingTableView"]),
    ],
    dependencies: [
        .package(name: "CleanArchitecture", path: "../CleanArchitecture"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.4.1"),
        .package(url: "https://github.com/CoderMJLee/MJRefresh.git", from: "3.7.9")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PagingTableView",
            dependencies: [
                .product(name: "CleanArchitecture", package: "CleanArchitecture"),
                .product(name: "CombineCocoa", package: "CombineCocoa"),
                .product(name: "MJRefresh", package: "MJRefresh")
            ]),

    ]
)

