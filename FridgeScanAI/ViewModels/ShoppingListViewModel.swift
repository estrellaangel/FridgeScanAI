import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class ShoppingListViewModel: ObservableObject {
    
    @Published var manualItems: [String] = []
    @Published var favoriteBasedItems: [String] = []
    
    //FAVORITES THAT ARE FOUND IN SCAN
    @Published var checkedItems: [String: Bool] = [:]
    
    //to check the recent scan
//    @EnvironmentObject var scanSession: ScanSessionViewModel

    private let db = Firestore.firestore()

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    var shoppingList: [String] {
        manualItems + favoriteBasedItems.filter { !(checkedItems[$0] ?? false) }
    }

    // MARK: - Fetch Manual Ingredients
    func fetchShoppingList(scanSessionVM: ScanSessionViewModel) {
        guard let userID else { return }

        let manualRef = db.collection("users").document(userID).collection("shoppingList").document("manualIngredients")
        let favoriteRef = db.collection("users").document(userID).collection("shoppingList").document("favoriteIngredients")

        manualRef.getDocument { manualSnapshot, manualError in
            if let manualData = manualSnapshot?.data(),
               let manual = manualData["items"] as? [String] {
                DispatchQueue.main.async {
                    self.manualItems = manual
                }
            } else {
                print("Couldn't load manual items: \(manualError?.localizedDescription ?? "No data")")
            }
        }

        favoriteRef.getDocument { favoriteSnapshot, favoriteError in
            if let favoriteData = favoriteSnapshot?.data(),
               let favorites = favoriteData["items"] as? [String] {
                DispatchQueue.main.async {
                    self.favoriteBasedItems = favorites

                    // ✅ After loading favorites, update checked items!
                    self.updateScannedIngredients(latestScanIngredients: scanSessionVM.latestScanIngredients)
                }
            } else {
                print("Couldn't load favorite items: \(favoriteError?.localizedDescription ?? "No data")")
            }
        }
    }



    // MARK: - Add Manual Ingredient
    func addManualItem(_ name: String) {
        guard let userID else { return }

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if !manualItems.contains(trimmed) {
            manualItems.append(trimmed)
            db.collection("users").document(userID).collection("shoppingList").document("manualIngredients")
                .setData(["items": manualItems], merge: true)
            print("!!!! - SHOULD HAVE SAVED " + trimmed)
        }
        
    }

    // MARK: - Update all ingredients
    func updateScannedIngredients(latestScanIngredients: [Ingredient]) {
        guard !latestScanIngredients.isEmpty else {
            print("No ingredients in latest scan, skipping update.")
            return
        }

        //UPDATE FAVORITES
        let scannedNames = latestScanIngredients.map { $0.name.lowercased() }

        for favorite in favoriteBasedItems {
            let favoriteLower = favorite.lowercased()

            var isChecked = false
            for scanned in scannedNames {
                if favoriteLower.contains(scanned) {
                    isChecked = true
//                    print("IS CHECKED IS TRUE !!!!!!!!!!!!!!")
                    break
                }
            }

            checkedItems[favorite] = isChecked
        }
        
        //UPDATE MANUAL
        let beforeCount = manualItems.count

        manualItems.removeAll { manual in
            let manualLower = manual.lowercased()
            for scanned in scannedNames {
                if manualLower.contains(scanned) {
                    print("🗑️ Removing manual item '\(manual)' because it matches scanned '\(scanned)'")
                    return true
                }
            }
            return false
        }

        let afterCount = manualItems.count
        if beforeCount != afterCount {
            print("Manual items reduced from \(beforeCount) to \(afterCount)")
            saveManualItems()
        } else {
            print("No manual items removed")
        }
        

    }


    func saveManualItems() {
        guard let userID else { return }
        let manualRef = db.collection("users").document(userID).collection("shoppingList").document("manualIngredients")
        
        print("Saving manual items to Firestore path: \(manualRef.path)")

        manualRef.setData(["items": manualItems], merge: true)
    }
    
    func deleteManualItem(_ item: String) {
        guard let userID else { return }
        manualItems.removeAll { $0 == item }

        db.collection("users").document(userID)
            .collection("shoppingList")
            .document("manualIngredients")
            .setData(["items": manualItems], merge: true)
    }



    // MARK: check if a favorite is checked
    func isChecked(_ item: String) -> Bool {
        return checkedItems[item] ?? false
    }
    
    func toggleChecked(for item: String) {
        checkedItems[item, default: false].toggle()
    }



}
