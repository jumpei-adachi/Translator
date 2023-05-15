// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Translator",
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "Translator",
			targets: ["Translator"]),
	],
	dependencies: [
		.package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.1"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "Translator",
			dependencies: [
				.product(name: "SQLite", package: "SQLite.swift"),
			]
		),
		.testTarget(
			name: "TranslatorTests",
			dependencies: ["Translator"]),
	]
)
