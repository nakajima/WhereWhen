//
//  SettingsView.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftUI

extension URL: Identifiable {
	public var id: URL { self }
}

struct SettingsView: View {
	@Environment(\.database) var database
	@Environment(LocationListener.self) var location

	@State private var exportURL: URL?

	var body: some View {
		List {
			Button(action: exportDatabase) {
				Text("Export Database")
			}
			.sheet(item: $exportURL) { url in
				ShareLink(item: url)
			}

			NavigationLink("Logs", destination: DiskLoggerViewer(logger: location.logger))

			Section {
				NavigationLink("Ignored Places", destination: IgnoredPlacesListView())
			}
		}
	}

	func exportDatabase() {
		var error: NSError?
		let coordinator = NSFileCoordinator()
		coordinator.coordinate(readingItemAt: URL.documentsDirectory, options: [.forUploading], error: &error) { zipUrl in
			let tmpUrl = try! FileManager.default.url(
				for: .itemReplacementDirectory,
				in: .userDomainMask,
				appropriateFor: zipUrl,
				create: true
			).appendingPathComponent("\(database.url.lastPathComponent).zip")

			try! FileManager.default.moveItem(at: zipUrl, to: tmpUrl)
			self.exportURL = tmpUrl
		}
	}
}
