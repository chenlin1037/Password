//
//  PassworldApp.swift
//  Passworld
//
//  Created by luckly on 2025/12/2.
//

import SwiftData
import SwiftUI

@main
struct PasswordApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(for: [Category.self, Account.self])
                .environmentObject(AdaptiveLayoutManager.shared)
        }
    }
}
