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
    @Query private var accounts: [Account]
    @State private var newAccountTitle = ""
    @Environment(\.modelContext) private var modelContext
    @State private var showingAccount = false
    var body: some View {
        VStack {
            Text("Hello \(profile.username)!")
            HStack{
                TextField("New Account", text: $newAccountTitle)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    addAccount()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newAccountTitle.isEmpty)
            }
            List {
                ForEach(accounts) { account in
                    HStack {
                        Button(account.name) {
                            accountDetails(name: account.name)
                            showingAccount = true
                        }
                        Spacer()
                        Text("\(account.amount)")
                    }
                }
            }
            .sheet(isPresented: $showingAccount) {
                AccountMenuView(profile: profile)
            }
            
        }
    }
    private func addAccount() {
        let newAccount = Account(name: newAccountTitle, amount: 0)
        modelContext.insert(newAccount)
        newAccountTitle = ""
    }
    private func accountDetails(name: String) {
        
    }
}
