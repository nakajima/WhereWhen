//
//  VisitLogsView.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/19/24.
//

import Foundation
import SwiftUI

struct VisitLogsView: View {
	@State var logs: String?

	var body: some View {
		VStack {
			if let logs {
				TextEditor(text: .constant(logs))
					.font(.caption)
					.frame(maxHeight: .infinity)
			} else {
				ContentUnavailableView("No visits logged.", systemImage: "location.slash")
				Text("No visits logged.")
			}
		}
		.toolbar {
			ToolbarItem {
				Button("Clear") {
					try? FileManager.default.removeItem(at: URL.documentsDirectory.appending(path: "visits.log"))
					logs = nil
				}
			}
		}
		.navigationTitle("Raw Visit Logs")
		.navigationBarTitleDisplayMode(.inline)
		.fontDesign(.monospaced)
	}
}

#if DEBUG
	#Preview {
		PreviewsWrapper {
			VisitLogsView(logs: """
			+34.13916862|-118.20117843|2024-06-15T21:18:22Z
			+34.13930740|-118.19875974|2024-06-15T21:20:28Z
			+34.14152163|-118.19031722|2024-06-15T21:24:13Z
			+34.14150908|-118.19024782|2024-06-16T18:47:04Z
			+34.15114012|-118.08090004|2024-06-16T19:00:18Z
			+34.15081918|-118.08125754|2024-06-16T19:21:10Z
			+34.13659182|-118.18925570|2024-06-16T19:35:18Z
			+34.13631584|-118.18918819|2024-06-16T19:36:56Z
			+34.14149840|-118.19024035|2024-06-16T19:38:45Z
			+34.14150145|-118.19024781|2024-06-17T20:48:24Z
			+34.14979138|-118.13681498|2024-06-17T20:56:19Z
			+34.14979138|-118.13681498|2024-06-17T20:56:19Z
			+34.15001137|-118.13654999|2024-06-17T21:53:28Z
			+34.14150684|-118.19046115|2024-06-17T22:03:11Z
			+34.14150053|-118.19024828|2024-06-18T14:07:15Z
			+34.11171285|-118.22422866|2024-06-18T14:21:48Z
			+34.11031194|-118.22561512|2024-06-18T14:26:19Z
			+34.07683027|-118.38129853|2024-06-18T15:05:04Z
			+34.07592230|-118.37761462|2024-06-18T15:06:52Z
			+34.14154389|-118.19032170|2024-06-18T15:43:05Z
			+34.14152477|-118.19024990|2024-06-18T20:12:26Z
			+34.09676197|-118.26658724|2024-06-18T20:30:04Z
			+34.09678132|-118.26670641|2024-06-18T20:53:10Z
			+34.14147425|-118.19084841|2024-06-18T21:07:51Z
			""")
		}
	}
#endif
