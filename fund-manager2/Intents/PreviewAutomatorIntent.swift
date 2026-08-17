//
//  PreviewAutomatorIntent.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import AppIntents
import SwiftData
import SwiftUI

struct PreviewAutomatorIntent: AppIntent {

    static var title: LocalizedStringResource {
        "Preview Automator"
    }

    static var description = IntentDescription(
        "Preview how Fund Manager's Automator would distribute an amount."
    )

    @Parameter(title: "Amount")
    var amount: Double

    static var parameterSummary: some ParameterSummary {
        Summary("Preview Automator with \(\.$amount)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {

        let container = try ModelContainer(
            for: Profile.self,
            Account.self,
            Snapshot.self
        )

        let modelContext = ModelContext(container)

        let accounts = try modelContext.fetch(
            FetchDescriptor<Account>()
        )

        let allocations = try AutomatorService.calculateAllocations(
            amount: amount,
            accounts: accounts
        )

        return .result(
            dialog: "Automator preview",
            view: AutomatorPreviewView(
                amount: amount,
                allocations: allocations
            )
        )
    }
}
