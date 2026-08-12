//
//  CreateAccountView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/11/26.
//
 
import SwiftUI
import SwiftData

struct CreateAccountView: View {
    let profile: Profile
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var accounts: [Account]
    @Query private var snapshots: [Snapshot]
    @State private var newAccountTitle = ""
    @State private var showingAccount = false
    @State private var gonnaExit = false
    @State private var selectedAccount: Account?
    var body: some View {
        VStack {
            Text("Let's Create An Account!")
            VStack{
                TextField("New Account", text: $newAccountTitle)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    addAccount()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newAccountTitle.isEmpty)
            }
        }
    }
    private func addAccount() {
        let newAccount = Account(name: newAccountTitle, amount: 0, percent: 0)
        modelContext.insert(newAccount)
        newAccountTitle = ""
        dismiss()
    }
}
