//
//  MKCoordinateRegion.swift
//  WhereWhen
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
	var id: String {
		return "\(center.latitude),\(center.longitude),\(span.latitudeDelta),\(span.longitudeDelta)"
	}
}
