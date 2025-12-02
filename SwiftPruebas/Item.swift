//
//  Item.swift
//  SwiftPruebas
//
//  Created by TOM STOVALL on 12/2/25.
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
