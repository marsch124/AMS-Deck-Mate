// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DeckMateCore",
    platforms: [.macOS(.v14)],
    products: [.library(name: "DeckMateCore", targets: ["DeckMateCore"])],
    targets: [
        .target(name: "DeckMateCore"),
        .testTarget(name: "DeckMateCoreTests", dependencies: ["DeckMateCore"]),
    ]
)
