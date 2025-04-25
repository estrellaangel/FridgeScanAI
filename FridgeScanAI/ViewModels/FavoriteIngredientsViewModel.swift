//
//  FavoriteIngredientsViewModel.swift
//  FridgeScanAI
//
//  Created by Sabrina Farias on 4/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class FavoriteIngredientsViewModel: ObservableObject {
    @Published var favoriteIngredients: [String] = []

    private let db = Firestore.firestore()

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    func fetchFavorites(shoppingListVM: ShoppingListViewModel? = nil,
                        scanSessionVM: ScanSessionViewModel? = nil) {
        guard let userID else { return }

        db.collection("users").document(userID).collection("favoriteIngredients").document("main")
            .getDocument { snapshot, error in
                if let data = snapshot?.data(),
                   let ingredients = data["items"] as? [String] {
                    DispatchQueue.main.async {
                        self.favoriteIngredients = ingredients

                        // Syncing with the newest list list
                        if let shoppingListVM, let scanSessionVM {
                            shoppingListVM.updateAfterScan(
                                newInventory: scanSessionVM.latestScanIngredients.map { $0.name },
                                favoriteIngredients: ingredients
                            )
                        }
                    }
                } else {
                    print("Couldn't load favorites: \(error?.localizedDescription ?? "No data")")
                }
        }
    }


    func addIngredient(_ name: String, shoppingListVM: ShoppingListViewModel, scanSessionVM: ScanSessionViewModel) {
        guard let userID else { return }

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !favoriteIngredients.contains(trimmed) else { return }

        favoriteIngredients.append(trimmed)

        db.collection("users").document(userID).collection("favoriteIngredients").document("main")
        .setData([
            "items": favoriteIngredients
        ], merge: false)

        // updaate shopping lsit
        shoppingListVM.updateAfterScan(
            newInventory: scanSessionVM.latestScanIngredients.map { $0.name },
            favoriteIngredients: self.favoriteIngredients
        )
    }


    func deleteIngredient(at index: Int, shoppingListVM: ShoppingListViewModel, scanSessionVM: ScanSessionViewModel) {
        guard let userID else { return }

        favoriteIngredients.remove(at: index)

        db.collection("users").document(userID).collection("favoriteIngredients").document("main")
        .setData([
            "items": favoriteIngredients
        ], merge: false) { error in
            if let error = error {
                print("❌ Firestore update failed: \(error)")
                return
            }

            print("Firestore updated with: \(self.favoriteIngredients)")
            self.fetchFavorites(shoppingListVM: shoppingListVM, scanSessionVM: scanSessionVM)
        }
    }
    
    func fetchFavoritesThenUpdateShoppingList(scanSessionVM: ScanSessionViewModel,
                                              shoppingListVM: ShoppingListViewModel) {
        guard let userID else { return }

        db.collection("users").document(userID).collection("favoriteIngredients").document("main")
            .getDocument { snapshot, error in
                if let data = snapshot?.data(),
                   let ingredients = data["items"] as? [String] {
                    DispatchQueue.main.async {
                        self.favoriteIngredients = ingredients
                        print("✅ Refetched favorites: \(ingredients)")

                        // ✅ Now use guaranteed fresh list
                        shoppingListVM.updateAfterScan(
                            newInventory: scanSessionVM.latestScanIngredients.map { $0.name },
                            favoriteIngredients: ingredients
                        )
                    }
                } else {
                    print("⚠️ Could not re-fetch favorites: \(error?.localizedDescription ?? "No data")")
                }
        }
    }

}
