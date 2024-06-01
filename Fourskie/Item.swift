//
//  Item.swift
//  Fourskie
//
//  Created by Pat Nakajima on 5/31/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
