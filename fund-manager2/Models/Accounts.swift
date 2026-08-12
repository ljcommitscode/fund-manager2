//
//  Accounts.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/23/26.
//

import Foundation
import SwiftData

@Model
class Account {
    var id = UUID()
    var name: String
    var amount: Double
    var percent: Double
    
    @Relationship(deleteRule: .cascade)
    var snapshots: [Snapshot]
    
    init(name: String, amount: Double, percent: Double) {
        self.name = name
        self.amount = amount
        self.percent = percent
        self.snapshots = []
    }
}
