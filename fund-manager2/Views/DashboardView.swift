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
    @State private var newAccount = false
    @State private var settings = false
    @State private var selectedAccount: Account?
    var body: some View {
        VStack {
            Text("Hello \(profile.username)!")
            .toolbar {
                ToolbarItemGroup {
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
            /*HStack{
                TextField("New Account", text: $newAccountTitle)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    addAccount()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newAccountTitle.isEmpty)
            }*/
            List {
                ForEach(accounts) { account in
                    HStack {
                        Button(account.name) {
                            selectedAccount = account
                            showingAccount = true
                        }
                        Spacer()
                        Text("\(account.amount)")
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
                UpdateMenuView(profile: profile)
            }
            .sheet(isPresented: $newAccount) {
                CreateAccountView(profile: profile)
            }
        }
    }
    private func addAccount() {
        let newAccount = Account(name: newAccountTitle, amount: 0, percent: 0)
        modelContext.insert(newAccount)
        newAccountTitle = ""
    }
}
