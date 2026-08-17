//
//  Dashboard.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/23/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    let profile: Profile
    
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @Query private var snapshots: [Snapshot]
    @State private var newAccountTitle = ""
    @State private var showingAccount = false
    @State private var gonnaUpdate = false
    @State private var gonnaAutomate = false
    @State private var newAccount = false
    @State private var settings = false
    @State private var selectedAccount: Account?
    
    private func accountChange(for account: Account) -> Double? {
        let accountSnapshots = snapshots
            .filter { $0.accountID == account.id }
            .sorted { $0.createdAt > $1.createdAt }

        guard accountSnapshots.count >= 2 else {
            return nil
        }

        let current = accountSnapshots[0].amount
        let previous = accountSnapshots[1].amount

        return current - previous
    }
    
    var body: some View {
        VStack {
            Text("Hello \(profile.username)!")
            .toolbar {
                ToolbarItemGroup {
                    Button("Auto") {
                        gonnaAutomate = true
                    }
                    
                    Button("Update") {
                        gonnaUpdate = true
                    }
                    Spacer()
                    Button("New Account") {
                        newAccount = true
                    }
                    Spacer()
                    Button("Settings") { //need to wire this in
                        settings = true
                    }
                }
            }
            List {
                ForEach(accounts) { account in
                    HStack {
                        Button(account.name) {
                            selectedAccount = account
                            showingAccount = true
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(account.amount.formatted(.currency(code: "USD")))
                            
                            if let change = accountChange(for: account) {
                                if change > 0 {
                                    Label(
                                        change.formatted(.currency(code: "USD")),
                                        systemImage: "arrow.up"
                                    )
                                    .foregroundStyle(.green)
                                    .font(.caption)
                                    
                                } else if change < 0 {
                                    Label(
                                        change.formatted(.currency(code: "USD")),
                                        systemImage: "arrow.down"
                                    )
                                    .foregroundStyle(.red)
                                    .font(.caption)
                                    
                                } else {
                                    Text("-")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("-")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAccount) {
                //unwraps optional
                if let account = selectedAccount {
                    AccountMenuView(profile: profile, selectedAccount: account)
                }
            }
            .sheet(isPresented: $gonnaUpdate) {
                UpdateMenuView()
            }
            .sheet(isPresented: $gonnaAutomate) {
                AutomatorView()
            }
            .sheet(isPresented: $newAccount) {
                CreateAccountView(profile: profile)
            }
            .sheet(isPresented: $settings) {
                SettingsView(profile: profile)
            }
        }
    }
}
