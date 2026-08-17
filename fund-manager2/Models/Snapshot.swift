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
    var accountID: UUID
    var amount: Double

    init(
        createdAt: Date,
        accountID: UUID,
        amount: Double
    ) {
        self.createdAt = createdAt
        self.accountID = accountID
        self.amount = amount
    }
}
