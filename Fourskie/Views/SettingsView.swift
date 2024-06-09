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

struct SyncServerEditorView: View {
	@EnvironmentObject var coordinator: FourskieCoordinator
	@Environment(\.database) var database

	@State private var serverURLText: String = ""
	@State private var status: Status = .editing

	@Binding var isEditingSync: Bool
	@FocusState var isFocused

	enum Status: Equatable {
		case editing, checking, error(String)
	}

	var body: some View {
		TextField("Enter Server URL…", text: $serverURLText)
			.focused($isFocused)
			.textInputAutocapitalization(.never)
			.onAppear {
				self.isFocused = true
			}
			.task(id: status) {
				if status == .checking {
					guard let url = URL(string: serverURLText) else {
						withAnimation {
							self.status = .error("Invalid URL")
						}
						return
					}

					let client = FourskieClient(serverURL: url)
					guard await client.isAvailable() else {
						withAnimation {
							self.status = .error("Unexpected server response.")
						}
						return
					}

					let syncer = Syncer(database: database, client: client)
					syncer.setup()
					coordinator.syncer = syncer

					withAnimation {
						isEditingSync = false
					}
				}
			}
		if case let .error(string) = status {
			Text(string)
				.foregroundStyle(.red)
				.font(.subheadline)
		}
		Button("Update") {
			withAnimation {
				status = .checking
			}
		}
		Button("Cancel", role: .cancel) {
			withAnimation {
				isEditingSync = false
			}
		}
		.tint(.secondary)
	}
}

struct SettingsView: View {
	@EnvironmentObject var coordinator: FourskieCoordinator
	@Environment(\.database) var database
	@Environment(LocationListener.self) var location

	@State private var isEditingSync = false

	@State private var exportURL: URL?

	var body: some View {
		List {
			Section("Sync Server") {
				if isEditingSync {
					SyncServerEditorView(isEditingSync: $isEditingSync)
				} else {
					if let syncer = coordinator.syncer {
						HStack {
							Text(syncer.clientURL.absoluteString)
								.textSelection(.enabled)
								.task {
									await coordinator.checkSyncServer()
								}
							Spacer()
							if coordinator.isSyncServerOnline {
								Text("Online")
									.font(.caption)
									.bold()
									.foregroundStyle(.green)
							} else {
								Text("Offline")
									.font(.caption)
									.bold()
									.foregroundStyle(.red)
							}
						}
						Button("Edit…") {
							withAnimation {
								isEditingSync = true
							}
						}
					} else {
						Button("Add Sync Server…") {
							withAnimation {
								isEditingSync = true
							}
						}
					}
				}
			}

			Section {
				NavigationLink("Ignored Places", destination: IgnoredPlacesListView())
			}

			Button(action: exportDatabase) {
				Text("Export Database")
			}
			.sheet(item: $exportURL) { url in
				ShareLink(item: url)
			}

			NavigationLink("Logs", destination: DiskLoggerViewer(logger: location.logger))

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

#if DEBUG
#Preview {
	PreviewsWrapper {
		SettingsView()
	}
}
#endif
