//
//  FridgeScanAIApp.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth

@main
struct FridgeScanAIApp: App {
    @StateObject private var scanSession = ScanSessionViewModel() // ✅ ADD THIS
    
    init() {
        FirebaseApp.configure()
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Anonymous auth failed: \(error.localizedDescription)")
            } else if let user = result?.user {
                print("Signed in anonymously as \(user.uid)")
            }
        }

    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(for: [FridgeContents.self, Ingredient.self])
                .environmentObject(scanSession)
        }
    }
}
