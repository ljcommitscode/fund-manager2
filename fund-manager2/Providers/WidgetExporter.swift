//
//  WidgetExporter.swift
//  fund-manager2
//


import Foundation
import WidgetKit

enum WidgetExporter {

    static let appGroupID =
        "group.com.UnoUnoStudios.fund-manager2"

    static let fileName =
        "widgetData.json"

    static func export(
        accounts: [Account],
        snapshots: [Snapshot]
    ) {

        print("🔥 WIDGET EXPORT: Started")
        print("🔥 WIDGET EXPORT: Accounts received: \(accounts.count)")
        print("🔥 WIDGET EXPORT: Snapshots received: \(snapshots.count)")

        let widgetAccounts = accounts.map { account in

            let accountSnapshots = snapshots
                .filter {
                    $0.accountID == account.id
                }
                .sorted {
                    $0.createdAt < $1.createdAt
                }

            print(
                "🔥 WIDGET EXPORT: \(account.name) has \(accountSnapshots.count) snapshots"
            )

            let widgetSnapshots = accountSnapshots.map { snapshot in
                WidgetSnapshot(
                    date: snapshot.createdAt,
                    amount: snapshot.amount
                )
            }

            return WidgetAccount(
                id: account.id,
                name: account.name,
                currentAmount: account.amount,
                snapshots: widgetSnapshots
            )
        }

        let widgetData = WidgetData(
            accounts: widgetAccounts,
            lastUpdated: Date()
        )

        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            print("🔥 WIDGET EXPORT: App Group unavailable")
            return
        }

        let fileURL =
            containerURL.appendingPathComponent(fileName)

        do {
            let data = try JSONEncoder().encode(widgetData)

            try data.write(
                to: fileURL,
                options: .atomic
            )

            print(
                "🔥 WIDGET EXPORT: Wrote \(widgetAccounts.count) accounts"
            )

            WidgetCenter.shared.reloadTimelines(
                ofKind: "ChartsWidget"
            )

            print(
                "🔥 WIDGET EXPORT: Timeline reload requested"
            )

        } catch {
            print(
                "🔥 WIDGET EXPORT: FAILED - \(error)"
            )
        }
    }

    static func export(
        profile: Profile,
        snapshots: [Snapshot]
    ) {
        export(
            accounts: profile.accounts,
            snapshots: snapshots
        )
    }
}
