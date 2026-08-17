//
//  AutomatorService.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import Foundation
import SwiftData

struct AutomatorAllocation: Identifiable {
    
    let id: UUID
    let accountName: String
    let currentAmount: Double
    let change: Double
    let updatedAmount: Double
    let percent: Double
    let isCollector: Bool
}

enum AutomatorError: LocalizedError {
    
    case invalidAmount
    case noCollector
    case invalidPercentages(Double)
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Please enter a valid dollar amount."
            
        case .noCollector:
            return "Please select an Extra Collector account in Automator Settings."
            
        case .invalidPercentages(let total):
            return "Your percentages must add up to 100%. They currently add up to \(total)%."
            
        case .saveFailed:
            return "Could not save the automator changes."
        }
    }
}

struct AutomatorService {
    
    // MARK: - Allocation Calculation
    
    static func calculateAllocations(
        amount: Double,
        accounts: [Account]
    ) throws -> [AutomatorAllocation] {
        
        guard amount.isFinite else {
            throw AutomatorError.invalidAmount
        }
        
        guard let collector = accounts.first(where: {
            $0.isExtraCollector
        }) else {
            throw AutomatorError.noCollector
        }
        
        let totalPercent = accounts.reduce(0) {
            $0 + $1.percent
        }
        
        guard abs(totalPercent - 100.0) <= 0.001 else {
            throw AutomatorError.invalidPercentages(totalPercent)
        }
        
        // Convert the amount to whole cents.
        //
        // This works for both positive and negative amounts.
        //
        // Example:
        //  $100.00 ->  10,000 cents
        // -$100.00 -> -10,000 cents
        //
        let totalCents = Int(
            (amount * 100).rounded()
        )
        
        var allocatedCents = 0
        
        var changes: [UUID: Int] = [:]
        
        // Calculate each account's percentage allocation.
        for account in accounts {
            
            let percentage = account.percent / 100.0
            
            let calculatedCents =
                Double(totalCents) * percentage
            
            let accountCents = Int(
                calculatedCents.rounded(.towardZero)
            )
            
            changes[account.id] = accountCents
            allocatedCents += accountCents
        }
        
        // Any leftover cents go to the Extra Collector.
        let remainingCents =
            totalCents - allocatedCents
        
        changes[collector.id, default: 0] += remainingCents
        
        return accounts.map { account in
            
            let changeCents =
                changes[account.id] ?? 0
            
            let change =
                Double(changeCents) / 100.0
            
            let updatedAmount =
                round(
                    (account.amount + change) * 100
                ) / 100
            
            return AutomatorAllocation(
                id: account.id,
                accountName: account.name,
                currentAmount: account.amount,
                change: change,
                updatedAmount: updatedAmount,
                percent: account.percent,
                isCollector: account.isExtraCollector
            )
        }
    }
    
    // MARK: - Apply Allocation
    
    static func apply(
        amount: Double,
        accounts: [Account],
        modelContext: ModelContext
    ) throws {
        
        let allocations = try calculateAllocations(
            amount: amount,
            accounts: accounts
        )
        
        // Apply the exact same allocation that was used
        // to generate the preview.
        for allocation in allocations {
            
            guard let account = accounts.first(where: {
                $0.id == allocation.id
            }) else {
                continue
            }
            
            account.amount = allocation.updatedAmount
        }
        
        // Save today's snapshot for every account.
        for account in accounts {
            saveTodaysSnapshot(
                accountID: account.id,
                accountAmount: account.amount,
                modelContext: modelContext
            )
        }
        
        do {
            try modelContext.save()
        } catch {
            throw AutomatorError.saveFailed
        }
    }
    
    // MARK: - Collector
    
    static func setCollector(
        id: PersistentIdentifier?,
        accounts: [Account]
    ) {
        
        for account in accounts {
            account.isExtraCollector =
                account.persistentModelID == id
        }
    }
    
    // MARK: - Percentage Validation
    
    static func totalPercentage(
        accounts: [Account]
    ) -> Double {
        
        accounts.reduce(0) {
            $0 + $1.percent
        }
    }
    
    static func percentagesAreValid(
        accounts: [Account]
    ) -> Bool {
        
        let total =
            totalPercentage(accounts: accounts)
        
        return abs(total - 100.0) <= 0.001
    }
    
    // MARK: - Snapshots
    
    private static func saveTodaysSnapshot(
        accountID: UUID,
        accountAmount: Double,
        modelContext: ModelContext
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
        
        if let existingSnapshots = try? modelContext.fetch(
            fetchDescriptor
        ) {
            
            let todaysSnapshots =
                existingSnapshots.filter { snapshot in
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
}
