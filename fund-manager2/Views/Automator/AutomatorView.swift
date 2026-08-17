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
                        Text(
                            "Enter an amount above to see the updated balances."
                        )
                        .foregroundStyle(.secondary)
                    } else {
                        ForEach(allocationPreview) { allocation in
                            AllocationPreviewRow(
                                allocation: allocation
                            )
                        }
                    }
                }
                
                Button("Apply Amount") {
                    automateAccounts()
                }
            }
            .navigationTitle("Automator")
            .alert(
                "Unable to Automate",
                isPresented: $showingError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Preview
    
    private var allocationPreview: [AutomatorAllocation] {
        
        guard let amount = Double(totalAmount) else {
            return []
        }
        
        return (
            try? AutomatorService.calculateAllocations(
                amount: amount,
                accounts: accounts
            )
        ) ?? []
    }
    
    // MARK: - Apply
    
    private func automateAccounts() {
        
        guard !totalAmount.isEmpty else {
            showError("Please enter an amount.")
            return
        }
        
        guard let amount = Double(totalAmount) else {
            showError(
                "Please enter a valid dollar amount."
            )
            return
        }
        
        do {
            try AutomatorService.apply(
                amount: amount,
                accounts: accounts,
                modelContext: modelContext
            )
            
            dismiss()
            
        } catch let error as AutomatorError {
            showError(
                error.localizedDescription
            )
            
        } catch {
            showError(
                "An unexpected error occurred."
            )
        }
    }
    
    // MARK: - Error Handling
    
    private func showError(
        _ message: String
    ) {
        errorMessage = message
        showingError = true
    }
}

// MARK: - Allocation Preview Row

private struct AllocationPreviewRow: View {
    
    let allocation: AutomatorAllocation
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 4
        ) {
            
            HStack {
                Text(allocation.accountName)
                
                Spacer()
                
                if allocation.isCollector {
                    Text("(Collector)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                
                Text(
                    allocation.currentAmount,
                    format: .currency(code: "USD")
                )
                .foregroundStyle(.secondary)
                
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                
                Text(
                    allocation.updatedAmount,
                    format: .currency(code: "USD")
                )
                .fontWeight(.semibold)
                
                Spacer()
                
                Text(
                    allocation.change,
                    format: .currency(code: "USD")
                )
                .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}
