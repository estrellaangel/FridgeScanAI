//
//  ScanSessionViewModel.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/19/25.
//

/*
 
 a central state manager for handling everything related to the most recent fridge scan, including:
 - Holding the latest scan results (ingredients)
 - Fetching scan data from Firebase Firebase
 - Saving and syncing ingredient data to Firebase
 - Working with other view models like FavoriteIngredientsViewModel and ShoppingListViewModel
 
 */

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import Foundation

class ScanSessionViewModel: ObservableObject {
    @Published var latestScanIngredients: [Ingredient] = [] // used to hold items detected in most recent scan
    @Published var latestScanID: String? = nil  // Firebase document ID for the latest scan
    @Published var videoURL: URL? = nil // Stores the video file path
    @Published var hasLoadedInitialScan: Bool = false   // Prevents redundant fetching
    
    // Reference to the Firebase database
    private let db = Firestore.firestore()
    
    func fetchLatestScan(favoriteVM: FavoriteIngredientsViewModel, shoppingListVM: ShoppingListViewModel) {
        print("Attempting to fetch latest scan...")
        
        // Checks if there is a currently authenticated user
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            return
        }

        db.collection("users").document(userID).collection("scans")
            // Orders by most recent scan
            .order(by: "timestamp", descending: true)
            // picks the latest document only
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch latest scan: \(error)")
                    return
                }

                // Skips if there is no previous scan to pull
                guard let document = snapshot?.documents.first else {
                    print("No previous scans found")
                    self.hasLoadedInitialScan = true
                    return
                }

                // Skips updating if the scan hasn’t changed
                let latestScanID = document.documentID
                if latestScanID == self.latestScanID {
                    print("Latest scan is the same — no need to update shopping list")
                    return
                }

                // if scan is found update favorite ingredients view model and shopping list model lists
                print("New scan found! Updating shopping list...")
                self.latestScanID = latestScanID
                self.setScan(from: document, favoriteVM: favoriteVM, shoppingListVM: shoppingListVM)
                self.hasLoadedInitialScan = true
            }
    }
    
    func updateLocalScan(with labels: [String]) {
        // Deduplicates the list of label strings
        let uniqueNames = Set(labels)
        let namesArray = Array(uniqueNames)
        
        // Fetches full Ingredient objects from the backend
        IngredientService.fetchIngredients(for: namesArray) { ingredients in
            DispatchQueue.main.async {
                self.latestScanIngredients = ingredients    // Updates latestScanIngredients
            }
        }
    }

    func setScan(from doc: DocumentSnapshot, favoriteVM: FavoriteIngredientsViewModel, shoppingListVM: ShoppingListViewModel, completion: (() -> Void)? = nil) {
        print("setScan triggered from Firestore doc")

        // Extracts the detectedIngredients field
        let data = doc.data() ?? [:]
        // Fetches the full Ingredient objects for those UIDs
        let uids = data["detectedIngredients"] as? [String] ?? []
        print("detectedIngredient UIDs: \(uids)")
        
        self.latestScanID = doc.documentID
        print("latestScanID set to: \(doc.documentID)")
        
        IngredientService.fetchIngredients(for: uids) { ingredients in
            DispatchQueue.main.async {
                self.latestScanIngredients = ingredients    // updates latestScanIngredients
                print("Updated latestScanIngredients: \(ingredients.map { $0.name })")
                shoppingListVM.updateScannedIngredients(latestScanIngredients: ingredients) // updates shopping list items
                
                completion?() // Call the completion after ingredients are updated
            }
        }
    }
    
    //Helper function to store most recent detected items to Firebase
    func UploadDetectionList(names: [String]) {
      guard
        let userID = Auth.auth().currentUser?.uid,
        let scanID = latestScanID
      else { return }

      let scanDoc = db
        .collection("users").document(userID)
        .collection("scans").document(scanID)

      scanDoc.setData(
        ["detectedIngredients": names],
        merge: true
      ) { error in
        if let e = error {
          print("Failed to upload list of detected fridge items:", e)
        } else {
          print("Uploaded \(names.count) detected UIDs to Firebase.")
        }
      }
    }

}
