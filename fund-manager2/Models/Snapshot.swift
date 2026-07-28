//
//  Snapshot.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/27/26.
//

import Foundation
import SwiftData

@Model
class Snapshot {
    var createdAt: Date
    var accountName: String
    var amount: Double
    
    
    init(createdAt: Date, name: String, amount: Double) {
        self.createdAt = .now
        self.accountName = name
        self.amount = amount
    }
}
