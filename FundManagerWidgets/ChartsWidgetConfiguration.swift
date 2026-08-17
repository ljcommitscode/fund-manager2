//
//  ChartsWidgetConfiguration.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import AppIntents

struct ChartsWidgetConfiguration: WidgetConfigurationIntent {

    static var title: LocalizedStringResource = "Charts Widget"

    static var description = IntentDescription(
        "Choose an account and graph style."
    )

    @Parameter(title: "Account")
    var account: WidgetAccountEntity?

    @Parameter(title: "Graph")
    var graph: GraphType?
}
