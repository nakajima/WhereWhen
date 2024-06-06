// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "FourskieServer",
	platforms: [.macOS(.v14), .iOS(.v17)],
	products: [
		.executable(name: "fourskie", targets: ["Command"]),
		.library(name: "LibFourskie", targets: ["LibFourskie"])
	],
	dependencies: [
		.package(url: "https://github.com/hummingbird-project/hummingbird", branch: "main"),
		.package(url: "https://github.com/apple/swift-argument-parser", branch: "main"),
		.package(url: "https://github.com/swift-server/async-http-client", branch: "main"),
		.package(url: "https://github.com/nakajima/ServerData.swift", branch: "main"),
		.package(url: "https://github.com/vapor/sqlite-kit", branch: "main")
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.executableTarget(
			name: "Command",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				"Server"
			]
		),
		.target(name: "LibFourskie"),
		.target(
			name: "Server",
			dependencies: [
				.product(name: "Hummingbird", package: "hummingbird"),
				.product(name: "AsyncHTTPClient", package: "async-http-client"),
				.product(name: "ServerData", package: "ServerData.swift"),
				.product(name: "SQLiteKit", package: "sqlite-kit"),
			]
		)
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
