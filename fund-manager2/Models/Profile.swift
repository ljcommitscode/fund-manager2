//
//  Profile.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/23/26.
//

import Foundation
import SwiftData

@Model
class Profile {
    var id = UUID()
    var username: String
    var darkmode: Bool
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var accounts: [Account]
    
    init(username: String, darkmode: Bool = false) {
        self.username = username
        self.darkmode = darkmode
        self.createdAt = .now
        self.accounts = []
    }
}
