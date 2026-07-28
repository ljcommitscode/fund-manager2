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
        let newSnap = Snapshot(createdAt: .now ,name: accountName, amount: accountAmount)
        modelContext.insert(newSnap)
    }

    private func saveChanges() {
        for account in accounts {
            guard
                let text = amounts[account.persistentModelID],
                let value = Double(text)
            else { continue }

            account.amount = value
            addSnap(accountName: text, accountAmount: value)
            
            dismiss()
        }

        try? modelContext.save()
    }
}
