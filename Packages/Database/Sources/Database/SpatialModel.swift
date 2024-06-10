//
//  SpatialModel.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/8/24.
//

import Foundation

public protocol SpatialModel: Model, Sendable {
	var coordinateSQL: String { get }
}
