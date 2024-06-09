//
//  Command.swift
//
//
//  Created by Pat Nakajima on 6/4/24.
//

import ArgumentParser
import Foundation
import Server

struct ServerCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "server")

	func run() async throws {
		try await Server().run()
	}
}

@main
struct Commands: AsyncParsableCommand {
	static let version = "wherewhen v0.0.1"

	static let configuration = CommandConfiguration(
		commandName: "wherewhen",
		abstract: "Stuff for wherewhen",
		version: version,
		subcommands: [ServerCommand.self]
	)
}
