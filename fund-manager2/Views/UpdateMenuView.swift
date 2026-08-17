import SwiftUI
import SwiftData

struct UpdateMenuView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var accounts: [Account]

    @State private var amounts: [PersistentIdentifier: String] = [:]

    var body: some View {
        NavigationStack {
            Form {
                ForEach(accounts) { account in
                    HStack {
                        Text(account.name)

                        Spacer()

                        TextField(
                            "0.00",
                            text: Binding(
                                get: {
                                    amounts[account.persistentModelID] ?? ""
                                },
                                set: { newValue in
                                    amounts[account.persistentModelID] =
                                        filteredMoneyInput(newValue)
                                }
                            )
                        )
                        .multilineTextAlignment(.trailing)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    }
                }

                Button("Save Changes") {
                    saveChanges()
                }
            }
            .navigationTitle("Update Accounts")
            .onAppear {
                populateFields()
            }
        }
    }
    
    private func filteredMoneyInput(_ input: String) -> String {
        var result = ""
        var hasDecimal = false
        var decimalPlaces = 0

        for character in input {

            // Allow a negative sign only as the first character.
            if character == "-" {
                if result.isEmpty {
                    result.append(character)
                }
                continue
            }

            // Allow only one decimal point.
            if character == "." {
                if !hasDecimal {
                    hasDecimal = true
                    result.append(character)
                }
                continue
            }

            // Allow numbers.
            if character.isNumber {

                // Once we have two digits after the decimal,
                // ignore any additional digits.
                if hasDecimal {
                    guard decimalPlaces < 2 else {
                        continue
                    }

                    decimalPlaces += 1
                }

                result.append(character)
            }
        }

        return result
    }
    private func populateFields() {
        for account in accounts {
            amounts[account.persistentModelID] = ""
        }
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

    private func saveChanges() {
        for account in accounts {
            guard
                let text = amounts[account.persistentModelID],
                let change = Double(text)
            else {
                continue
            }

            let originalAmount = account.amount
            let newAmount = originalAmount + change

            account.amount = newAmount

            addSnapshot(
                accountID: account.id,
                accountAmount: newAmount
            )
        }

        try? modelContext.save()
        dismiss()
    }
}
