// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "UnicodeEmoji",
  platforms: [.iOS(.v11)],
  products: [
    .library(name: "UnicodeEmoji", targets: ["UnicodeEmoji"]),
  ],
  targets: [
    .target(name: "UnicodeEmoji", dependencies: [], path: "Sources"),
    .target(name: "UnicodeEmojiExample",
            dependencies: ["UnicodeEmoji"],
            path: "UnicodeEmojiExample")
  ]
)
