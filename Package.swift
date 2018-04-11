// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "TrashBoat",
	products: [
		.library(name: "TrashBoat", targets: ["TrashBoat"]),
	],
	dependencies: [
		.package(url: "https://github.com/Takanu/Pelican.git", .revision("2f847cdf72308a7657edf92f7c67ce740049b2d9")),
	],
	targets: [
		.target(name: "TrashBoat", dependencies: ["Pelican"]),
	]
)

