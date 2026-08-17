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
        AutomatorService.totalPercentage(
            accounts: accounts
        )
    }
    
    var body: some View {
        VStack {
            
            Text("Automator Settings")
                .font(.title)
                .padding()
            
            Spacer()
            
            Section("Extra Collector") {
                Picker(
                    "Account",
                    selection: $selectedCollectorID
                ) {
                    Text("None")
                        .tag(
                            Optional<PersistentIdentifier>.none
                        )
                    
                    ForEach(accounts) { account in
                        Text(account.name)
                            .tag(
                                Optional(
                                    account.persistentModelID
                                )
                            )
                    }
                }
            }
            .onAppear {
                selectedCollectorID =
                    accounts.first(where: {
                        $0.isExtraCollector
                    })?.persistentModelID
            }
            
            VStack {
                
                ForEach(accounts) { account in
                    
                    HStack {
                        
                        Text(account.name)
                        
                        Spacer()
                        
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
            .alert(
                "Invalid Percentages",
                isPresented: $showingPercentError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(
                    "Your percentages must add up to 100%. " +
                    "They currently add up to " +
                    "\(totalPercent)%. "
                )
            }
        }
    }
    
    // MARK: - Save
    
    private func saveChanges() {
        
        guard AutomatorService.percentagesAreValid(
            accounts: accounts
        ) else {
            showingPercentError = true
            return
        }
        
        AutomatorService.setCollector(
            id: selectedCollectorID,
            accounts: accounts
        )
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print(
                "Could not save Automator settings: \(error)"
            )
        }
    }
}
