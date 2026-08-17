//
//  WidgetSharedData.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import Foundation

struct WidgetSnapshot: Codable {
    let date: Date
    let amount: Double
}

struct WidgetAccount: Codable {
    let id: UUID
    let name: String
    let currentAmount: Double
    let snapshots: [WidgetSnapshot]
}

struct WidgetData: Codable {
    let accounts: [WidgetAccount]
    let lastUpdated: Date
}
