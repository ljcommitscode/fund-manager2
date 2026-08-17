//
//  WidgetAccountEntity.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//
import AppIntents
import Foundation

struct WidgetAccountEntity: AppEntity {

    typealias ID = UUID

    static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Account")

    static let defaultQuery = WidgetAccountQuery()

    let id: UUID
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)"
        )
    }
}

struct WidgetAccountQuery: EntityQuery {

    func entities(
        for identifiers: [WidgetAccountEntity.ID]
    ) async throws -> [WidgetAccountEntity] {

        guard !identifiers.isEmpty else {
            return []
        }

        guard let widgetData = WidgetDataLoader.load() else {
            return []
        }

        return widgetData.accounts.compactMap { account in
            guard identifiers.contains(account.id) else {
                return nil
            }

            return WidgetAccountEntity(
                id: account.id,
                name: account.name
            )
        }
    }

    func suggestedEntities()
        async throws -> [WidgetAccountEntity]
    {
        print("🔥 Widget account query running")

        guard let widgetData = WidgetDataLoader.load() else {
            print("🔥 Widget account query: NO WIDGET DATA")
            return []
        }

        print("🔥 Widget account query accounts: \(widgetData.accounts.count)")

        return widgetData.accounts.map { account in
            WidgetAccountEntity(
                id: account.id,
                name: account.name
            )
        }
    }

    func defaultResult()
        async -> WidgetAccountEntity?
    {
        do {
            return try await suggestedEntities().first
        } catch {
            return nil
        }
    }
}
