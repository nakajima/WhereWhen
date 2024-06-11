// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Database",
	platforms: [.iOS(.v17)],
	products: [
		.library(
			name: "Database",
			targets: ["Database"]
		),
	],
	dependencies: [
		.package(path: "../LibWhereWhen"),
		.package(url: "https://github.com/groue/GRDB.swift", branch: "master"),
	],
	targets: [
		.target(
			name: "Database",
			dependencies: [
				"LibWhereWhen",
				.product(name: "GRDB", package: "GRDB.swift"),
			]
		),
		.testTarget(
			name: "DatabaseTests",
			dependencies: ["Database"]
		),
	]
)
