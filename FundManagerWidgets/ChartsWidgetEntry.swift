//
//  ChartsWidgetEntry.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import WidgetKit

struct ChartsWidgetEntry: TimelineEntry {

    let date: Date

    let accountName: String
    let currentAmount: Double
    let snapshots: [WidgetSnapshot]

    let graphType: GraphType
}
