//
//  ErrorOverlay.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import SwiftUI

struct ErrorOverlay: View {
	@EnvironmentObject var coordinator: FourskieCoordinator

	let message: String

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Error occurred:")
				.frame(maxWidth: .infinity, alignment: .leading)
				.font(.caption)
				.bold()

			Text(message)
			Button("Dismiss", role: .cancel) {
				coordinator.dismissError()
			}
			.controlSize(.mini)
			.buttonStyle(.bordered)
			.tint(.white)
		}
		.frame(maxWidth: .infinity)
		.foregroundStyle(.white)
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 24)
				.fill(.red)
				.shadow(radius: 2)
		)
		.padding()
		.dragDismissable {
			coordinator.dismissError()
		}
	}
}
