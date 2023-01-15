// swift-tools-version: 5.7
import PackageDescription

let package = Package(
	name: "Catcher",
	platforms: [
		.iOS(.v11),
		.watchOS(.v4),
		.macOS(.v10_13),
		.tvOS(.v11)
	],
	products: [
		.library(
			name: "Catcher",
			targets: ["Catcher"]
		),
	],
	dependencies: [],
	targets: [
		.target(
			name: "Catcher",
			dependencies: []
		),
		.testTarget(
			name: "CatcherTests",
			dependencies: ["Catcher"]
		)
	]
)
