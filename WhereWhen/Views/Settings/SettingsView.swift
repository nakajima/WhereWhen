//
//  SettingsView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import SwiftUI

extension URL: Identifiable {
	public var id: URL { self }
}

@MainActor struct SettingsView: View {
	@Environment(\.coordinator) var coordinator
	@Environment(\.database) var database
	@Environment(\.location) var location

	@State private var isEditingSync = false

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

			NavigationLink(value: Route.exportData) {
				Text("Export Your Data")
			}

			Section {
				NavigationLink("Visit Log \(visitLogFileSize())", destination: VisitLogsView(logs: try? String(contentsOf: URL.documentsDirectory.appending(path: "visits.log"))))
				NavigationLink("Application Logs \(logFileSize())", destination: DiskLoggerViewer(logger: location.logger))
			}

			PlaceResolverDebuggerView()

			Section("Visit Importer") {
				NavigationLink("Import Visits", value: Route.settingsVisitImporter)
			}
		}
		.refreshable {
			await coordinator.checkSyncServer()
		}
		.navigationTitle("Settings")
	}

	func visitLogFileSize() -> String {
		let path = URL.documentsDirectory.appending(path: "visits.log").path

		guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else {
			return ""
		}

		let size = attributes[.size] as? UInt64 ?? UInt64(0)

		return "(" + ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file) + ")"
	}

	func logFileSize() -> String {
		let path = location.logger.location.path

		guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else {
			return ""
		}

		let size = attributes[.size] as? UInt64 ?? UInt64(0)

		return "(" + ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file) + ")"
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			SettingsView()
		}
	}
#endif
