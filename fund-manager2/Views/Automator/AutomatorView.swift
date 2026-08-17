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
    
    private struct AllocationPreview: Identifiable {
        let id: UUID
        let accountName: String
        let currentAmount: Double
        let change: Double
        let updatedAmount: Double
        let percent: Double
        let isCollector: Bool
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount to Add") {
                    MoneyTextField(
                        text: $totalAmount,
                        placeholder: "0.00"
                    )
                    .frame(height: 22)
                }

                Section("Accounts") {
                    ForEach(accounts) { account in
                        HStack {
                            Text(account.name)

                            Spacer()

                            if account.isExtraCollector {
                                Text("(Collector)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(
                                "\(account.percent, specifier: "%.2f")%"
                            )
                            .foregroundStyle(.secondary)

                        }
                    }
                }
                
                Section("Preview") {
                    if allocationPreview.isEmpty {
                        Text("Enter an amount above to see the updated balances.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(allocationPreview) { preview in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(preview.accountName)

                                    Spacer()

                                    if preview.isCollector {
                                        Text("(Collector)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                HStack {
                                    Text(
                                        preview.currentAmount,
                                        format: .currency(code: "USD")
                                    )
                                    .foregroundStyle(.secondary)

                                    Image(systemName: "arrow.right")
                                        .foregroundStyle(.secondary)

                                    Text(
                                        preview.updatedAmount,
                                        format: .currency(code: "USD")
                                    )
                                    .fontWeight(.semibold)

                                    Spacer()

                                    Text(
                                        preview.change,
                                        format: .currency(code: "USD")
                                    )
                                    .foregroundStyle(.secondary)
                                }
                                .font(.subheadline)
                            }
                            .padding(.vertical, 2)
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
                calculatedCents.rounded(.towardZero)
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
        if remainingCents != 0 {

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
    
    private var allocationPreview: [AllocationPreview] {

        guard let enteredAmount = Double(totalAmount) else {
            return []
        }

        let totalCents = Int(
            (enteredAmount * 100).rounded()
        )

        var allocatedCents = 0

        var changes: [UUID: Int] = [:]

        // Calculate the normal percentage allocations.
        for account in accounts {

            let percentage = account.percent / 100.0

            let calculatedCents =
                Double(totalCents) * percentage

            let accountCents = Int(
                calculatedCents.rounded(.towardZero)
            )

            changes[account.id] = accountCents
            allocatedCents += accountCents
        }

        // Give the remainder to the collector.
        let remainingCents = totalCents - allocatedCents

        if let collector = accounts.first(where: {
            $0.isExtraCollector
        }) {
            changes[collector.id, default: 0] += remainingCents
        }

        return accounts.map { account in

            let changeCents = changes[account.id] ?? 0

            let change = Double(changeCents) / 100.0

            let updatedAmount = round(
                (account.amount + change) * 100
            ) / 100

            return AllocationPreview(
                id: account.id,
                accountName: account.name,
                currentAmount: account.amount,
                change: change,
                updatedAmount: updatedAmount,
                percent: account.percent,
                isCollector: account.isExtraCollector
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
