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
    
    private let db = Firestore.firestore()
    
    func fetchLatestScan(favoriteVM: FavoriteIngredientsViewModel, shoppingListVM: ShoppingListViewModel) {
        print("Attempting to fetch latest scan...")
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user")
            return
        }

        db.collection("users").document(userID).collection("scans")
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

                let latestScanID = document.documentID
                if latestScanID == self.latestScanID {
                    print("🔵 Latest scan is the same — no need to update shopping list")
                    return
                }

                print("✅ New scan found! Updating shopping list...")
                self.latestScanID = latestScanID
                self.setScan(from: document, favoriteVM: favoriteVM, shoppingListVM: shoppingListVM)

                self.hasLoadedInitialScan = true
            }
    }


    func setScan(from doc: DocumentSnapshot, favoriteVM: FavoriteIngredientsViewModel, shoppingListVM: ShoppingListViewModel, completion: (() -> Void)? = nil) {
        print("setScan triggered from Firestore doc")

        let data = doc.data() ?? [:]
        let uids = data["detectedIngredients"] as? [String] ?? []
        print("detectedIngredient UIDs: \(uids)")
        
        self.latestScanID = doc.documentID
        print("📸 latestScanID set to: \(doc.documentID)")
        
        IngredientService.fetchIngredients(for: uids) { ingredients in
            DispatchQueue.main.async {
                self.latestScanIngredients = ingredients
                print("Updated latestScanIngredients: \(ingredients.map { $0.name })")

                shoppingListVM.updateScannedIngredients(latestScanIngredients: ingredients)
                
                completion?() // ✅ Call the completion after ingredients are updated
            }
        }
    }

}
