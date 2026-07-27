//
//  CreateProfileView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/23/26.
//

import SwiftUI
import SwiftData

struct CreateProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var newUser = ""
    
    var body: some View {
        VStack {
            Text("No Profiles Yet!")
            TextField("Username", text: $newUser)
                .textFieldStyle(.roundedBorder)
            Button("Create"){
                createProfile()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    private func createProfile() {
        let newProfile = Profile(username: newUser)
        modelContext.insert(newProfile)
        newUser = ""
    }
}
