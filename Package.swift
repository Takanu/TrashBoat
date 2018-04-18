// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "TrashBoat",
	products: [
		.library(name: "TrashBoat", targets: ["TrashBoat"]),
	],
	dependencies: [
        .package(url: "https://github.com/Takanu/Pelican.git", .upToNextMinor(from: "0.8.0")),
	],
	targets: [
		.target(name: "TrashBoat", dependencies: ["Pelican"]),
	]
)

