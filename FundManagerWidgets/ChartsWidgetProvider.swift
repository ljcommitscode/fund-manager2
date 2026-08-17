//
//  ChartsWidgetProvider.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import Foundation
import WidgetKit

struct ChartsWidgetProvider: AppIntentTimelineProvider {

    typealias Entry = ChartsWidgetEntry
    typealias Intent = ChartsWidgetConfiguration

    func placeholder(
        in context: Context
    ) -> ChartsWidgetEntry {

        ChartsWidgetEntry(
            date: Date(),
            accountName: "Checking",
            currentAmount: 1250,
            snapshots: [],
            graphType: .line
        )
    }

    func snapshot(
        for configuration: ChartsWidgetConfiguration,
        in context: Context
    ) async -> ChartsWidgetEntry {

        makeEntry(
            configuration: configuration
        )
    }

    func timeline(
        for configuration: ChartsWidgetConfiguration,
        in context: Context
    ) async -> Timeline<ChartsWidgetEntry> {

        let entry = makeEntry(
            configuration: configuration
        )

        return Timeline(
            entries: [entry],
            policy: .never
        )
    }

    private func makeEntry(
        configuration: ChartsWidgetConfiguration
    ) -> ChartsWidgetEntry {

        let graphType = configuration.graph ?? .line

        guard let selectedAccount = configuration.account else {
            return ChartsWidgetEntry(
                date: Date(),
                accountName: "Select Account",
                currentAmount: 0,
                snapshots: [],
                graphType: graphType
            )
        }

        guard let widgetData = WidgetDataLoader.load() else {
            return ChartsWidgetEntry(
                date: Date(),
                accountName: "No Data",
                currentAmount: 0,
                snapshots: [],
                graphType: graphType
            )
        }

        guard let account = widgetData.accounts.first(
            where: { account in
                account.id == selectedAccount.id
            }
        ) else {
            return ChartsWidgetEntry(
                date: Date(),
                accountName: "Account Not Found",
                currentAmount: 0,
                snapshots: [],
                graphType: graphType
            )
        }

        return ChartsWidgetEntry(
            date: Date(),
            accountName: account.name,
            currentAmount: account.currentAmount,
            snapshots: account.snapshots,
            graphType: graphType
        )
    }
}
