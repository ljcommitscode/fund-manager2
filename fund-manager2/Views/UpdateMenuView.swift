import SwiftUI
import SwiftData

struct UpdateMenuView: View {

    let profile: Profile

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var accounts: [Account]

    @State private var amounts: [PersistentIdentifier: String] = [:]
    @State private var newSnapTitle = ""

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
                                set: {
                                    amounts[account.persistentModelID] = $0
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

    private func populateFields() {
        for account in accounts {
            amounts[account.persistentModelID] = String(account.amount)
        }
    }
    
    private func addSnap(accountName: String, accountAmount: Double) {
        let now = Date()
        let calendar = Calendar.current
        
        // 1. Calculate boundaries
        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        // 2. Fetch snapshots matching ONLY the name (keeps the predicate simple)
        let fetchDescriptor = FetchDescriptor<Snapshot>(
            predicate: #Predicate<Snapshot> { snapshot in
                snapshot.accountName == accountName
            }
        )
        
        // 3. Filter for today's dates manually and delete them
        if let existingSnaps = try? modelContext.fetch(fetchDescriptor) {
            let todaysSnaps = existingSnaps.filter { snap in
                snap.createdAt >= startOfDay && snap.createdAt < endOfDay
            }
            
            for snap in todaysSnaps {
                modelContext.delete(snap)
            }
        }
        
        // 4. Insert the new snapshot
        let newSnap = Snapshot(createdAt: now, name: accountName, amount: accountAmount)
        modelContext.insert(newSnap)
    }


    private func saveChanges() {
        for account in accounts {
            guard
                let text = amounts[account.persistentModelID],
                let value = Double(text)
            else { continue }

            account.amount = value
            // Note: You probably want to pass account.name here instead of text
            addSnap(accountName: account.name, accountAmount: value)
        }

        try? modelContext.save()
        dismiss() // Move this here so it executes AFTER the loop completes
    }
}
