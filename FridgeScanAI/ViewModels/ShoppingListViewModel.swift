//
//  ShoppingListViewModel.swift
//  FridgeScanAI
//
//  Created by Sabrina Farias 4/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ShoppingListViewModel: ObservableObject {
    @Published var manualItems: [String] = []
    @Published var favoriteBasedItems: [String] = []

    // Combined list shown in the UI
    var shoppingList: [String] {
        manualItems + favoriteBasedItems
    }

    private let db = Firestore.firestore()

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Firebase

    func fetchShoppingList() {
        guard let userID else { return }

        db.collection("users").document(userID).collection("shoppingList").document("main")
            .getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    let manual = data["manualItems"] as? [String] ?? []
                    let favoriteBased = data["favoriteBasedItems"] as? [String] ?? []

                    DispatchQueue.main.async {
                        self.manualItems = manual
                        self.favoriteBasedItems = favoriteBased
                    }
                } else {
                    print("Could not load shopping list: \(error?.localizedDescription ?? "No data")")
                }
        }
    }

    private func saveShoppingList() {
        guard let userID else { return }

        db.collection("users").document(userID).collection("shoppingList").document("main").setData([
            "manualItems": manualItems,
            "favoriteBasedItems": favoriteBasedItems
        ], merge: true)
    }

    // MARK: - User Actions

    func addItem(_ name: String) {
        guard let userID else { return }

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if !manualItems.contains(trimmed) && !favoriteBasedItems.contains(trimmed) {
            manualItems.append(trimmed)
            saveShoppingList()
        }
    }

    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            if index < manualItems.count {
                manualItems.remove(at: index)
            } else {
                let adjustedIndex = index - manualItems.count
                if adjustedIndex < favoriteBasedItems.count {
                    favoriteBasedItems.remove(at: adjustedIndex)
                }
            }
        }
        saveShoppingList()
    }

    // MARK: - Auto Sync Logic

    func updateAfterScan(newInventory: [String], favoriteIngredients: [String]) {
        let inventorySet = Set(newInventory.map { $0.lowercased() })

        // 1. Remove inventory items from manualItems and favoriteBasedItems
        manualItems.removeAll { inventorySet.contains($0.lowercased()) }
        favoriteBasedItems.removeAll { inventorySet.contains($0.lowercased()) }

        // 2. Re-add favorite items only if NOT in inventory and NOT already present
        let manualSet = Set(manualItems.map { $0.lowercased() })
        favoriteBasedItems = favoriteIngredients.filter { fav in
            let lowercasedFav = fav.lowercased()
            return !inventorySet.contains(lowercasedFav) &&
                   !manualSet.contains(lowercasedFav)
        }


        saveShoppingList()
    }
}
