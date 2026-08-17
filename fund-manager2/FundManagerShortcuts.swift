//
//  FundManagerShortcuts.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import AppIntents

struct FundManagerShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {

        AppShortcut(
            intent: RunAutomatorIntent(),
            phrases: [
                "Run Automator in \(.applicationName)",
                "Run \(.applicationName) Automator"
            ],
            shortTitle: "Run Automator",
            systemImageName: "arrow.triangle.2.circlepath"
        )

        AppShortcut(
            intent: PreviewAutomatorIntent(),
            phrases: [
                "Preview Automator in \(.applicationName)",
                "Preview \(.applicationName) Automator"
            ],
            shortTitle: "Preview Automator",
            systemImageName: "eye"
        )
    }
}
