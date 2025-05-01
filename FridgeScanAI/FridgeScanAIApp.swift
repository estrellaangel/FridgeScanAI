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
    @StateObject private var scanSession = ScanSessionViewModel()
    
    //ADDED BY SABRINA FOR SHOPPING LIST & FAV INGREDIENTS
    @StateObject private var favoriteVM = FavoriteIngredientsViewModel()
    @StateObject private var shoppingListVM = ShoppingListViewModel()
    
    //RECIPES
    @StateObject private var recipeVM = RecipeViewModel()
    
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
                .environmentObject(favoriteVM)  // ADDED BY SABRINA
                .environmentObject(shoppingListVM)  // ADDED BY SABRINA
                .environmentObject(recipeVM)
        }
    }
}
