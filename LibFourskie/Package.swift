// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "LibFourskie",
	platforms: [.macOS(.v14), .iOS(.v17)],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "LibFourskie",
			targets: ["LibFourskie"]
		),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "LibFourskie"),
		.testTarget(
			name: "LibFourskieTests",
			dependencies: ["LibFourskie"]
		),
	]
)

let swiftSettings: [SwiftSetting] = [
	.enableExperimentalFeature("StrictConcurrency"),
	.enableUpcomingFeature("DisableOutwardActorInference"),
]

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: swiftSettings)
	target.swiftSettings = settings
}
