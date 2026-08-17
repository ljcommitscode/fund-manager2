//
//  WidgetDataLoader.swift
//  fund-manager2
//

import Foundation

enum WidgetDataLoader {

    static let appGroupID =
        "group.com.UnoUnoStudios.fund-manager2"

    static let fileName =
        "widgetData.json"

    static func load() -> WidgetData? {

        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            print("🔥 WIDGET: App Group container unavailable")
            return nil
        }

        let fileURL = containerURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("🔥 WIDGET: widgetData.json does not exist")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)

            let widgetData = try JSONDecoder().decode(
                WidgetData.self,
                from: data
            )

            print("🔥 WIDGET: Loaded \(widgetData.accounts.count) accounts")

            for account in widgetData.accounts {
                print(
                    "🔥 WIDGET: \(account.name) has \(account.snapshots.count) snapshots"
                )
            }
            
            return widgetData

        } catch {
            print("🔥 WIDGET: Failed to load widget data: \(error)")
            return nil
        }
    }
}
