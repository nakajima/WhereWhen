//
//  Query+DatabaseQueue.swift
//  Fourskie
//
//  Created by Pat Nakajima on 6/7/24.
//

import Foundation
import GRDB
import GRDBQuery
import SwiftUI

// Convenience Query initializers for requests that feed from `DatabaseQueue`.
// From https://swiftpackageindex.com/groue/grdbquery/0.8.0/documentation/grdbquery/gettingstarted#Feed-a-SwiftUI-View
extension Query where Request.DatabaseContext == DatabaseQueue {
	/// Creates a `Query`, given an initial `Queryable` request that
	/// uses `DatabaseQueue` as a `DatabaseContext`.
	init(_ request: Request) {
		self.init(request, in: \.database.queue)
	}

	/// Creates a `Query`, given a SwiftUI binding to a `Queryable`
	/// request that uses `DatabaseQueue` as a `DatabaseContext`.
	init(_ request: Binding<Request>) {
		self.init(request, in: \.database.queue)
	}

	/// Creates a `Query`, given a ``Queryable`` request that uses
	/// `DatabaseQueue` as a `DatabaseContext`.
	init(constant request: Request) {
		self.init(constant: request, in: \.database.queue)
	}
}
