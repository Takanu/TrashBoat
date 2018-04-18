// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "TrashBoat",
	products: [
		.library(name: "TrashBoat", targets: ["TrashBoat"]),
	],
	dependencies: [
		.package(url: "https://github.com/Takanu/Pelican.git", .revision("9b3c3111b243c26242b91972ca17081f6ae1229c")),
	],
	targets: [
		.target(name: "TrashBoat", dependencies: ["Pelican"]),
	]
)

