//
//  RunAutomatorIntent.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import AppIntents
import SwiftData

struct RunAutomatorIntent: AppIntent {

    static var title: LocalizedStringResource {
        "Run Automator"
    }

    static var description = IntentDescription(
        "Apply an amount of money using Fund Manager's Automator."
    )

    @Parameter(title: "Amount")
    var amount: Double

    static var parameterSummary: some ParameterSummary {
        Summary("Run Automator with \(\.$amount)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {

        let container = try ModelContainer(
            for: Profile.self,
            Account.self,
            Snapshot.self
        )

        let modelContext = ModelContext(container)

        let descriptor = FetchDescriptor<Account>()

        let accounts = try modelContext.fetch(descriptor)

        try AutomatorService.apply(
            amount: amount,
            accounts: accounts,
            modelContext: modelContext
        )

        return .result(
            dialog: "Automator applied \(amount, format: .currency(code: "USD"))."
        )
    }
}
