//
//  AccountMenuView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/27/26.
//

import SwiftUI
import SwiftData
import Charts

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
    
    var body: some View {
        VStack {
            Text(selectedAccount.name)
            Text("\(selectedAccount.amount)")
            Text("\(selectedAccount.id)")
            ForEach(snapshots) { snap in
                if snap.accountName == selectedAccount.name {
                    Text("\(snap.createdAt)")
                    Text("\(snap.amount)")
                    Spacer()
                }
            }
        }
    }
}
