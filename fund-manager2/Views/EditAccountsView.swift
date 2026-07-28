//
//  EditAccounts.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/27/26.
//

import SwiftUI
import SwiftData

struct EditAccountsView: View {
    
    let profile: Profile
    let selectedAccount: Account
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Text(selectedAccount.name)
            Spacer()
            Text("\(selectedAccount.amount)")
            Spacer()
            Text("\(selectedAccount.id)")
        }
    }
}
