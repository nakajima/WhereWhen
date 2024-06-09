//
//  WhereWhenApp.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 5/31/24.
//

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
	let location = LocationListener(database: .dev)

	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		true
	}
}

@main
struct WhereWhenApp: App {
	@UIApplicationDelegateAdaptor var appDelegate: AppDelegate
	@StateObject var coordinator: WhereWhenCoordinator

	init() {
		_coordinator = StateObject(wrappedValue: WhereWhenCoordinator(database: .dev))
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(coordinator)
		}
		.environment(appDelegate.location)
		.environment(\.database, .dev)
	}
}
