//
//  AutomatorView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/16/26.

import SwiftUI
import SwiftData

struct AutomatorView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var accounts: [Account]

    @State private var totalAmount = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount to Add") {
                    TextField("0.00", text: $totalAmount)
                        .multilineTextAlignment(.trailing)

#if os(iOS)
                        .keyboardType(.numbersAndPunctuation)
#endif
                }

                Section("Accounts") {
                    ForEach(accounts) { account in
                        HStack {
                            Text(account.name)

                            Spacer()

                            Text("\(account.percent, specifier: "%.2f")%")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Button("Apply Amount") {
                    automateAccounts()
                }
            }
            .navigationTitle("Automator")
        }
    }

    private func automateAccounts() {
        guard let enteredAmount = Double(totalAmount) else {
            return
        }

        for account in accounts {
            let originalAmount = account.amount

            let percentage = account.percent / 100.0

            let accountChange = enteredAmount * percentage

            let newAmount = originalAmount + accountChange

            account.amount = newAmount

            addSnapshot(
                accountID: account.id,
                accountAmount: newAmount
            )
        }

        try? modelContext.save()
        dismiss()
    }

    private func addSnapshot(
        accountID: UUID,
        accountAmount: Double
    ) {
        let now = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)

        guard let endOfDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay
        ) else {
            return
        }

        let fetchDescriptor = FetchDescriptor<Snapshot>(
            predicate: #Predicate<Snapshot> { snapshot in
                snapshot.accountID == accountID
            }
        )

        if let existingSnapshots = try? modelContext.fetch(fetchDescriptor) {
            let todaysSnapshots = existingSnapshots.filter { snapshot in
                snapshot.createdAt >= startOfDay &&
                snapshot.createdAt < endOfDay
            }

            for snapshot in todaysSnapshots {
                modelContext.delete(snapshot)
            }
        }

        let newSnapshot = Snapshot(
            createdAt: now,
            accountID: accountID,
            amount: accountAmount
        )

        modelContext.insert(newSnapshot)
    }
}
