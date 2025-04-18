//
//  FridgeScanAIApp.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI
import SwiftData

@main
struct FridgeScanAIApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(for: [FridgeContents.self, Ingredient.self])
        }
    }
}
