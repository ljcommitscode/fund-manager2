//
//  ContentView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/23/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @Query(sort: \Profile.createdAt)
    private var profiles: [Profile]

    var body: some View {

        if let profile = profiles.first {

            NavigationStack {
                DashboardView(profile: profile)
            }

        } else {

            NavigationStack {
                CreateProfileView()
            }

        }

    }
}



