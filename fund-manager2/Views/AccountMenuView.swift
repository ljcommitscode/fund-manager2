//
//  AccountMenuView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/27/26.
//

import SwiftUI
import SwiftData
import Charts
import Foundation

struct AccountMenuView: View {
    
    let profile: Profile
    let selectedAccount: Account
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var sevenDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: today)!
    }
    
    @Environment(\.modelContext) private var modelContext
    @Query private var snapshots: [Snapshot]
    @State private var rawSelectedDate: Date?
    @State private var selectedValue: Double?
    private var filteredSnapshots: [Snapshot] {
        snapshots.filter { $0.accountName == selectedAccount.name }
    }
    
    var body: some View {
        VStack {
            Text(selectedAccount.name)
                .font(.headline)
            Spacer()
            Chart {
                ForEach(filteredSnapshots) { snap in
                    BarMark(
                        x: .value("Day", snap.createdAt, unit: .day),
                        y: .value("Amount", snap.amount)
                    )
                }
            }
            
        }
    }
}
