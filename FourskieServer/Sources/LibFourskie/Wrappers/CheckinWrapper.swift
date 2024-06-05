//
//  File.swift
//  
//
//  Created by Pat Nakajima on 6/5/24.
//

import Foundation

public protocol CheckinWrapper {
	var wrapped: Checkin { get }
	init(wrapped: Checkin)
}
