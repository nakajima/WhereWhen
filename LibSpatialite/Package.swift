// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "LibSpatialite",
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "LibSpatialite",
			targets: ["LibSpatialite"]
		),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "LibSpatialite",
			dependencies: ["libspatialite"]
		),
		.binaryTarget(
			name: "libspatialite",
			url: "https://github.com/nakajima/libspatialite-ios/releases/download/0.0.2/libspatialite.xcframework.zip",
			checksum: "78d47d8713d5774b50f7272cb8d8aa2b46ddede7b6ec4441b52e3ca2f2fe5e3d"
		),
		.testTarget(
			name: "LibSpatialiteSwiftTests",
			dependencies: ["LibSpatialite"]
		),
	]
)
