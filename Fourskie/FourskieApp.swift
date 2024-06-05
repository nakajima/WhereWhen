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
	let location = LocationListener()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		true
	}
}

@main
struct FourskieApp: App {
	@UIApplicationDelegateAdaptor var appDelegate: AppDelegate

	var sharedModelContainer: ModelContainer = {
		let schema = Schema([
			Checkin.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.environment(appDelegate.location)
		.modelContainer(sharedModelContainer)
	}
}
