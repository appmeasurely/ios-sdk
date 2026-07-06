// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AppMeasurely",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AppMeasurely",
            targets: ["AppMeasurely"]
        ),
    ],
    targets: [
        .target(
            name: "AppMeasurely",
            path: "Sources/AppMeasurely"
        )
    ]
)
