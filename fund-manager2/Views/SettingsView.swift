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
    
    // Track the currently active icon. nil represents the primary/default app icon.
    @State private var selectedAppIcon: String? = UIApplication.shared.alternateIconName
    
    // Define your available icons here.
    // The value should match the exact key name in your Info.plist, and nil is the primary app icon.
    private let availableIcons: [(name: String, identifier: String?)] = [
        ("Default Icon", nil),
        ("Dark Brandon Icon", "DarkIcon"),
        ("Trump Stocks Icon", "TrumpIcon")
        // Add more custom icons here if you have them, e.g.:
        // ("Neon Icon", "NeonIcon")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 15) {
                Button("Division Automator Settings") {
                    toAutomator = true
                }
                .sheet(isPresented: $toAutomator){
                    AutomatorSettingsView(profile: profile)
                }
                
                // App Icon Picker Dropdown
                if UIApplication.shared.supportsAlternateIcons {
                    Picker("App Icon", selection: $selectedAppIcon) {
                        ForEach(availableIcons, id: \.identifier) { icon in
                            Text(icon.name).tag(icon.identifier as String?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onChange(of: selectedAppIcon) {
                        changeAppIcon(to: selectedAppIcon)
                    }
                }
            }
        }
    }
    
    // Function that changes the app icon based on the dropdown selection
    private func changeAppIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        // Prevent calling setAlternateIconName with the same icon
        guard UIApplication.shared.alternateIconName != iconName else { return }
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to change icon: \(error.localizedDescription)")
            } else {
                print("Successfully changed app icon.")
            }
        }
    }
}
