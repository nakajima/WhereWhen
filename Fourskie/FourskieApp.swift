//
//  FourskieApp.swift
//  Fourskie
//
//  Created by Pat Nakajima on 5/31/24.
//

import SwiftData
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
	let location = LocationListener(container: ModelContainer.shared)

	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		true
	}
}

@main
struct FourskieApp: App {
	@UIApplicationDelegateAdaptor var appDelegate: AppDelegate
	@StateObject var coordinator = FourskieCoordinator()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(coordinator)
		}
		.environment(appDelegate.location)
		.modelContainer(ModelContainer.shared)
	}
}
