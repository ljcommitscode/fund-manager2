//
//  AutomatorView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/16/26.
//

import Foundation
import SwiftUI
import SwiftData

struct AutomatorView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var accounts: [Account]

    @State private var totalAmount = ""
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount to Add") {
                    TextField(
                        "0.00",
                        text: Binding(
                            get: {
                                totalAmount
                            },
                            set: { newValue in
                                totalAmount = filteredMoneyInput(newValue)
                            }
                        )
                    )
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

                            Text(
                                "\(account.percent, specifier: "%.2f")%"
                            )
                            .foregroundStyle(.secondary)

                            if account.isExtraCollector {
                                Text("Collector")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Button("Apply Amount") {
                    automateAccounts()
                }
            }
            .navigationTitle("Automator")
            .alert("Unable to Automate", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Money Input

    private func filteredMoneyInput(_ input: String) -> String {

        // Keep only numbers and decimal points.
        let filtered = input.filter {
            $0.isNumber || $0 == "."
        }

        // Only allow one decimal point.
        let components = filtered.split(
            separator: ".",
            omittingEmptySubsequences: false
        )

        if components.count > 2 {
            return totalAmount
        }

        // Limit the decimal portion to two digits.
        if components.count == 2 {
            let wholePart = String(components[0])
            let decimalPart = String(components[1])

            let limitedDecimal = String(
                decimalPart.prefix(2)
            )

            return "\(wholePart).\(limitedDecimal)"
        }

        return filtered
    }

    // MARK: - Automator

    private func automateAccounts() {

        guard !totalAmount.isEmpty else {
            showError("Please enter an amount.")
            return
        }

        guard let enteredAmount = Double(totalAmount) else {
            showError("Please enter a valid dollar amount.")
            return
        }

        guard enteredAmount >= 0 else {
            showError("The amount cannot be negative.")
            return
        }

        guard let collector = accounts.first(where: {
            $0.isExtraCollector
        }) else {
            showError(
                "Please select an Extra Collector account in Automator Settings."
            )
            return
        }

        // Convert the entered amount into whole cents.
        //
        // Example:
        // $100.00 -> 10,000 cents
        //
        // From this point forward, the Automator works entirely
        // with whole cents.
        let totalCents = Int(
            (enteredAmount * 100).rounded()
        )

        var allocatedCents = 0

        // First distribute the calculated cents to every account.
        for account in accounts {

            let percentage = account.percent / 100.0

            // Calculate this account's share in cents.
            let calculatedCents =
                Double(totalCents) * percentage

            // Only allocate whole cents.
            let accountCents = Int(
                floor(calculatedCents + 0.000000001)
            )

            allocatedCents += accountCents

            // Convert cents back into dollars.
            let accountChange =
                Double(accountCents) / 100.0

            account.amount = round(
                (account.amount + accountChange) * 100
            ) / 100
        }

        // Determine how many cents were not allocated because
        // of percentage rounding.
        let remainingCents =
            totalCents - allocatedCents

        // Give every remaining penny to the Extra Collector.
        if remainingCents > 0 {

            let collectorChange =
                Double(remainingCents) / 100.0

            collector.amount = round(
                (collector.amount + collectorChange) * 100
            ) / 100
        }

        // Create/update today's snapshot for every account
        // using the final account amount.
        for account in accounts {
            addSnapshot(
                accountID: account.id,
                accountAmount: account.amount
            )
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            showError(
                "Could not save the automator changes."
            )
        }
    }

    // MARK: - Error Handling

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }

    // MARK: - Snapshots

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

        if let existingSnapshots = try? modelContext.fetch(
            fetchDescriptor
        ) {
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
