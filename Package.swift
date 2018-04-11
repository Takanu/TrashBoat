// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "TrashBoat",
	products: [
		.library(name: "TrashBoat", targets: ["TrashBoat"]),
	],
	dependencies: [
		.package(url: "https://github.com/Takanu/Pelican.git", .branch("master")),
	],
	targets: [
		.target(name: "TrashBoat", dependencies: ["Pelican"]),
	]
)

