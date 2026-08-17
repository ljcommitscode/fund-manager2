//
//  ChartsWidget.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import SwiftUI
import WidgetKit

struct ChartsWidget: Widget {

    let kind = "ChartsWidget"

    var body: some WidgetConfiguration {

        AppIntentConfiguration(
            kind: kind,
            intent: ChartsWidgetConfiguration.self,
            provider: ChartsWidgetProvider()
        ) { entry in

            ChartsWidgetView(entry: entry)
        }
        .configurationDisplayName("Charts")
        .description(
            "View an account's recent balance history."
        )
        .supportedFamilies([
            .systemLarge
        ])
    }
}
