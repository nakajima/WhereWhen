//
//  Checkin+Spatial.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/8/24.
//

import Foundation
import LibWhereWhen
import Database

extension Checkin: SpatialModel {
	public var coordinateSQL: String { coordinate.sql }
}
