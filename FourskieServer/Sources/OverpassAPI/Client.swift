//
//  File.swift
//  
//
//  Created by Pat Nakajima on 6/6/24.
//

import Foundation

public struct OverpassResult {

}

// So we can use URLSession or AsyncHTTPClient
public protocol OverpassHTTPAdapter {
	func request(url: URL, params: [String: String], body: Data?) async throws -> Data?
}

public protocol Coordinate {
	var latitude: Double { get }
	var longitude: Double { get }
}

public struct OverpassClient {
	let baseURL: URL
	let adapter: OverpassHTTPAdapter

	public init(baseURL: URL, adapter: OverpassHTTPAdapter) {
		self.baseURL = baseURL
		self.adapter = adapter
	}

	public func named(near coordinate: some Coordinate, within radius: Double) async throws -> [OverpassResult] {
		let query = """
		[out:json];
		(
		node["name"](around:\(radius),\(coordinate.latitude),\(coordinate.longitude));
		way["name"](around:\(radius),\(coordinate.latitude),\(coordinate.longitude));
		);
		out body;
		>;
		out skel qt;
		"""

		let data = try await request(body: Data(query.utf8))
		
		return []
	}

	public func request(params: [String: String] = [:], body: Data?) async throws -> Data? {
		try await adapter.request(url: baseURL, params: params, body: body)
	}
}
