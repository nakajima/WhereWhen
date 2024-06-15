//
//  SyncServerEditorView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/11/24.
//

import SwiftUI

struct SyncServerEditorView: View {
	@EnvironmentObject var coordinator: WhereWhenCoordinator
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
			.onSubmit {
				status = .checking
			}
			.task(id: status) {
				guard status == .checking else {
					return
				}

				if serverURLText == "" {
					withAnimation {
						coordinator.syncer?.teardown()
						coordinator.syncer = nil
						isEditingSync = false
					}
				}

				guard let url = URL(string: serverURLText) else {
					withAnimation {
						self.status = .error("Invalid URL")
					}
					return
				}

				let client = WhereWhenClient(serverURL: url)
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

#if DEBUG
	#Preview {
		PreviewsWrapper {
			SyncServerEditorView(isEditingSync: .constant(true))
		}
	}
#endif
