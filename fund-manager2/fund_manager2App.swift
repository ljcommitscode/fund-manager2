//
//  fund_manager2App.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/23/26.
//

import SwiftUI
import SwiftData

@main
struct fund_manager2App: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [
                Profile.self,
                Account.self,
                Snapshot.self
            ]
        )
    }
}
