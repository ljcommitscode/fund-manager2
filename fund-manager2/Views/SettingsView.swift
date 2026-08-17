//
//  SettingsView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/15/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    let profile: Profile
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var accounts: [Account]
    @Query private var snapshots: [Snapshot]
    @State private var newAccountTitle = ""
    @State private var toAutomator = false
    @State private var selectedAccount: Account?
    var body: some View {
        VStack {
            Text("Settings")
            VStack{
                Button("Division Automator Settings") {
                    toAutomator = true
                }
                .sheet(isPresented: $toAutomator){
                    AutomatorSettingsView(profile: profile)
                }
            }
        }
    }
}
