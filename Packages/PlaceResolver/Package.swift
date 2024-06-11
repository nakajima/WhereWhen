// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "PlaceResolver",
	platforms: [.iOS(.v17)],
	products: [
		.library(
			name: "PlaceResolver",
			targets: ["PlaceResolver"]
		),
	],
	dependencies: [
		.package(path: "../Database"),
		.package(path: "../LibWhereWhen"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "PlaceResolver",
			dependencies: [
				"Database",
				"LibWhereWhen",
			]
		),
		.testTarget(
			name: "PlaceResolverTests",
			dependencies: [
				"PlaceResolver",
				"Database",
				"LibWhereWhen",
			]
		),
	]
)
