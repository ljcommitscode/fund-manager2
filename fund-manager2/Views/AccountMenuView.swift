//
//  AccountMenuView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/27/26.
//

import SwiftUI
import SwiftData

struct AccountMenuView: View {
    
    let profile: Profile
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Text("Hello, \(profile.username)")
        }
    }
}
