//
//  AutomatorSettingsView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/15/26.
//

import SwiftUI
import SwiftData

struct AutomatorSettingsView: View {
    
    let profile: Profile
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var accounts: [Account]
    
    @State private var showingPercentError = false
    @State private var selectedCollectorID: PersistentIdentifier?
    
    private var totalPercent: Double {
        accounts.reduce(0) { total, account in
            total + account.percent
        }
    }
    
    var body: some View {
        VStack {
            
            Text("Automator Settings")
                .font(.title)
                .padding()
            
            Spacer()
            
            Section("Extra Collector") {
                Picker("Account", selection: $selectedCollectorID) {
                    Text("None")
                        .tag(Optional<PersistentIdentifier>.none)

                    ForEach(accounts) { account in
                        Text(account.name)
                            .tag(Optional(account.persistentModelID))
                    }
                }
            }
            .onAppear {
                selectedCollectorID = accounts.first(where: {
                    $0.isExtraCollector
                })?.persistentModelID
            }
            
            VStack {
                
                ForEach(accounts) { account in
                    
                    HStack {
                        
                        // Account name
                        Text(account.name)
                        
                        Spacer()
                        
                        // Percentage text field
                        TextField(
                            "Percent",
                            value: Binding(
                                get: {
                                    account.percent
                                },
                                set: { newValue in
                                    account.percent = newValue
                                }
                            ),
                            format: .number
                        )
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        
                        Text("%")
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            Button("Save") {
                saveChanges()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .alert("Invalid Percentages", isPresented: $showingPercentError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your percentages must add up to 100%. They currently add up to \(totalPercent)%.")
            }
        }
    }
    
    private func saveChanges() {
        
        
        if abs(totalPercent - 100) > 0.001 {
            showingPercentError = true
            return
        }
        
        for account in accounts {
            account.isExtraCollector =
                account.persistentModelID == selectedCollectorID
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Could not save changes: \(error)")
        }
    }
}
