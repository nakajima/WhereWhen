//
//  VisitImporter.swift
//
//
//  Created by Pat Nakajima on 6/11/24.
//

import Foundation
import LibWhereWhen

public struct VisitImporter: Hashable, Equatable {
	public let lines: [Line]

	public init(from string: String) {
		var lines: [Line] = []
		var lastLine: Line?
		string.enumerateLines { line, _ in
			if let line = Line(string: line) {
				if let lastLine, lastLine.coordinate.within(50, of: line.coordinate) {
					return
				}

				lines.append(line)
				lastLine = line
			}
		}

		self.lines = lines
	}

	init(lines: [Line]) {
		self.lines = lines
	}

	public var id: String {
		lines.map(\.description).joined(separator: "\n")
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public struct Line: Equatable, Identifiable, CustomStringConvertible {
		public var id: String { description }

		public let latitude: Double
		public let longitude: Double
		public let timestamp: Date

		init(latitude: Double, longitude: Double, timestamp: Date) {
			self.latitude = latitude
			self.longitude = longitude
			self.timestamp = timestamp
		}

		public init?(string: String) {
			let parts = string.components(separatedBy: "|")

			guard parts.count == 3 else {
				return nil
			}

			guard let latitude = Double(parts[0]),
			      let longitude = Double(parts[1]),
			      let timestamp = ISO8601DateFormatter().date(from: parts[2])
			else {
				return nil
			}

			self.latitude = latitude
			self.longitude = longitude
			self.timestamp = timestamp
		}

		public var coordinate: Coordinate {
			Coordinate(latitude, longitude)
		}

		public var description: String {
			"\(latitude)|\(longitude)|\(ISO8601DateFormatter().string(from: timestamp))"
		}
	}
}
