//
//  ScanSessionViewModel.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/19/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class ScanSessionViewModel: ObservableObject {
    @Published var latestScanIngredients: [Ingredient] = []
    @Published var latestScanID: String? = nil
    @Published var videoURL: URL? = nil
    
    @Published var hasLoadedInitialScan: Bool = false
    
    // CHECKED ITEMS FOR RECIPES
        @Published var checkedItems: [String: Bool] = [:]
            
        func toggleChecked(for item: String) {
            checkedItems[item, default: false].toggle()
        }

        func initializeCheckedItems(for ingredients: [String]) {
            for item in ingredients {
                if checkedItems[item] == nil {
                    checkedItems[item] = false
                }
            }
        }
    
        func isIngredientChecked(ingredientOriginal: String, ingredientName: String) -> Bool {
            let loweredOriginal = ingredientOriginal.lowercased()
            let loweredName = ingredientName.lowercased()
            return loweredOriginal.contains(loweredName) && (checkedItems[ingredientName] ?? false)
        }
    
        func matchesDetectedIngredient(ingredientOriginal: String) -> Bool {
            let loweredOriginal = ingredientOriginal.lowercased()
            for detected in latestScanIngredients {
                let loweredDetected = detected.name.lowercased()
                if loweredOriginal.contains(loweredDetected) {
                    return true
                }
            }
            return false
        }
    
        func toggleDetectedIngredient(for ingredient: DecodableIngredient) {
            let loweredOriginal = ingredient.original.lowercased()
            
            for detected in latestScanIngredients {
                let loweredDetected = detected.name.lowercased()
                if loweredOriginal.contains(loweredDetected) {
                    // If match exists, toggle the checkedItems for that detected ingredient
                    let current = checkedItems[detected.name] ?? false
                    checkedItems[detected.name] = !current
                    break
                }
            }
        }


    // CHECKED ITEMS FOR RECIPES
    
    private let db = Firestore.firestore()
    
    func fetchLatestScan(favoriteVM: FavoriteIngredientsViewModel, shoppingListVM: ShoppingListViewModel) {
        print("Attempting to fetch latest scan...")
        
        guard let userID = Auth.auth().currentUser?.uid else { // this is the user id will need for all user specific data
            print("❌ No authenticated user")
            return
        }

        db.collection("users").document(userID).collection("scans") // this looks through users then is per collection ex: 'favoriteIngredients' t
//          .whereField("userID", isEqualTo: userID)  // not needed anymore
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch latest scan: \(error)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No previous scans found")
                    self.hasLoadedInitialScan = true
                    return
                }

                print("Latest scan fetched with ID: \(document.documentID)")
                self.setScan(from: document, favoriteVM: favoriteVM, shoppingListVM: shoppingListVM)
                
                self.hasLoadedInitialScan = true
                
                
            }
        
//        isNewScanCreated = true

    }

    func setScan(from doc: DocumentSnapshot, favoriteVM: FavoriteIngredientsViewModel, shoppingListVM: ShoppingListViewModel) {
        print("setScan triggered from Firestore doc")

        let data = doc.data() ?? [:]
        let uids = data["detectedIngredients"] as? [String] ?? []
        print("detectedIngredient UIDs: \(uids)")
        
        self.latestScanID = doc.documentID // ✅ ADD THIS LINE
        print("📸 latestScanID set to: \(doc.documentID)")
        
        IngredientService.fetchIngredients(for: uids) { ingredients in
            DispatchQueue.main.async {
                self.latestScanIngredients = ingredients
                print("Updated latestScanIngredients: \(ingredients.map { $0.name })")
                
                
                favoriteVM.fetchFavoritesThenUpdateShoppingList(
                    scanSessionVM: self,
                    shoppingListVM: shoppingListVM
                )
                
            }
        }
        
        
    }
}
