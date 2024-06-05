//
//  File.swift
//  
//
//  Created by Pat Nakajima on 6/4/24.
//

import Foundation
import AsyncHTTPClient

struct NominatimClient {
	var url: URL

	func check() async throws -> Bool {
		let request = HTTPClientRequest(url: url.appending(path: "status").absoluteString)
		let response = try await HTTPClient.shared.execute(request, timeout: .seconds(10))
		return response.status == .ok
	}
}
