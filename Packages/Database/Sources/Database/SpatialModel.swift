//
//  SpatialModel.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/8/24.
//

import Foundation
import LibWhereWhen

public protocol SpatialModel: Model, Sendable {
	var coordinate: Coordinate { get }
}
