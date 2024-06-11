import Foundation
import OSLog

extension Data {
	func append(to fileURL: URL) throws {
		if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
			defer {
				fileHandle.closeFile()
			}
			fileHandle.seekToEndOfFile()
			fileHandle.write(self)
		} else {
			try write(to: fileURL, options: .atomic)
		}
	}
}

private class Truncator {
	static func truncate(at url: URL, toLineCount lineCount: Int) throws {
		guard let reader = Truncator(url: url) else {
			return
		}

		// Use a buffer to keep the last `lineCount` lines
		var buffer = [String]()
		buffer.reserveCapacity(lineCount)

		// Read each line and maintain only the last `lineCount` lines in the buffer
		for line in reader {
			if buffer.count >= lineCount {
				buffer.removeFirst()
			}
			buffer.append(line)
		}

		// Write the contents of buffer to the file
		let newContents = buffer.joined(separator: "\n")
		try newContents.write(to: url, atomically: true, encoding: .utf8)
	}

	let fileHandle: FileHandle
	let bufferLength: Int
	var buffer: Data

	init?(url: URL, bufferLength: Int = 4096) {
		guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
		self.fileHandle = handle
		self.bufferLength = bufferLength
		self.buffer = Data(capacity: bufferLength)
	}

	deinit {
		fileHandle.closeFile()
	}

	func nextLine() -> String? {
		// Keep reading until a newline character is found
		while true {
			if let range = buffer.range(of: Data([0x0A]), options: [], in: buffer.startIndex ..< buffer.endIndex) {
				// Extract the line
				let line = String(data: buffer.subdata(in: buffer.startIndex ..< range.lowerBound), encoding: .utf8)
				buffer.removeSubrange(buffer.startIndex ... range.lowerBound)
				return line
			}
			let tempData = fileHandle.readData(ofLength: bufferLength)
			if tempData.isEmpty {
				return nil
			}
			buffer.append(tempData)
		}
	}
}

extension Truncator: Sequence {
	func makeIterator() -> AnyIterator<String> {
		return AnyIterator {
			self.nextLine()
		}
	}
}

public struct DiskLogger: Sendable {
	public let label: String
	public let location: URL
	public let maxLines: Int

	public enum LogType: String, Sendable {
		case trace, debug, info, warning, error, fault, critical
	}

	public struct Entry: Sendable {
		static let formatter = ISO8601DateFormatter()

		public let label: String
		public let timestamp: Date
		public let level: LogType
		public let text: String

		init(label: String, timestamp: Date, level: LogType, text: String) {
			self.label = label
			self.timestamp = timestamp
			self.level = level
			self.text = text
		}

		init?(string: String) {
			let parts = string.split(separator: "\t", maxSplits: 3).map { String($0) }

			guard parts.count == 4,
			      let level = LogType(rawValue: parts[1].lowercased()),
			      let timestamp = Entry.formatter.date(from: parts[2])
			else {
				return nil
			}

			self.label = parts[0]
			self.level = level
			self.timestamp = timestamp
			self.text = parts[3]
		}
	}

	var entries: [Entry] = []

	public mutating func truncate() throws {
		try Truncator.truncate(at: location, toLineCount: maxLines)
	}

	public mutating func clear() throws {
		try FileManager.default.removeItem(at: location)
		entries = []
	}

	public mutating func load() {
		do {
			entries = try String(contentsOf: location, encoding: .utf8).split(separator: "\n").compactMap { Entry(string: String($0)) }
		} catch {
			entries = [
				Entry(label: "DiskLogger", timestamp: Date(), level: .error, text: error.localizedDescription),
			]
		}
	}

	public nonisolated init(label: String = Bundle.main.bundleIdentifier!, location: URL, maxLines: Int = 1024) {
		self.label = label
		self.location = location
		self.maxLines = maxLines

		if !FileManager.default.fileExists(atPath: location.path) {
			FileManager.default.createFile(atPath: location.path, contents: Data())
		}
	}

	public func trace(_ message: String) {
		write(.trace, message)
	}

	public func warning(_ message: String) {
		write(.warning, message)
	}

	public func info(_ message: String) {
		write(.info, message)
	}

	public func debug(_ message: String) {
		write(.debug, message)
	}

	public func error(_ message: String) {
		write(.error, message)
	}

	public func fault(_ message: String) {
		write(.fault, message)
	}

	public func critical(_ message: String) {
		write(.critical, message)
	}

	func write(_ level: LogType, _ message: String) {
		do {
			let text = "\(label)\t\(level.rawValue.uppercased())\t\(Date().ISO8601Format())\t\(message)\n"
			try Data(text.utf8).append(to: location)
		} catch {}

		switch level {
		case .trace, .debug:
			os_log(.debug, "\(message)")
		case .info:
			os_log(.info, "\(message)")
		case .warning, .error:
			os_log(.error, "\(message)")
		case .fault, .critical:
			os_log(.fault, "\(message)")
		}
	}
}
