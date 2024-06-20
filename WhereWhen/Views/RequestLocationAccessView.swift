//
//  RequestLocationAccessView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/20/24.
//

import CoreLocationUI
import Foundation
import SwiftUI

struct RequestLocationAccessView: View {
	@Environment(LocationListener.self) var location
	@AppStorage("isLocationPromptDismissed") var isLocationPromptDismissed = false
	@Environment(\.openURL) var openURL

	var body: some View {
		if !location.isAuthorized, !isLocationPromptDismissed {
			VStack {
				switch location.manager.authorizationStatus {
				case .notDetermined:
					Button(action: {
						location.requestAuthorization()
					}) {
						Text("Grant Location Access…")
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(.borderedProminent)
					.buttonBorderShape(.capsule)
				case .denied:
					Text("Location access not authorized, checkins will not be added automatically. [Open settings to grant access.](#)")
						.environment(\.openURL, OpenURLAction { _ in
							print(openURL(URL(string: UIApplication.openSettingsURLString)!))
							return .handled
						})
						.foregroundStyle(.secondary)
				default:
					EmptyView()
				}
			}
			.frame(maxWidth: .infinity)
			.padding()
			.background(.fill)
			.font(.subheadline)
		}
	}
}
