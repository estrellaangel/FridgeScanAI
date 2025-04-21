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
    
    private let db = Firestore.firestore()
    
    func fetchLatestScan() {
        print("Attempting to fetch latest scan...")

        db.collection("scans")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch latest scan: \(error)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No previous scans found")
                    return
                }

                print("Latest scan fetched with ID: \(document.documentID)")
                self.setScan(from: document)
            }
    }

    func setScan(from doc: DocumentSnapshot) {
        print("setScan triggered from Firestore doc")

        let data = doc.data() ?? [:]
        let uids = data["detectedIngredients"] as? [String] ?? []
        print("detectedIngredient UIDs: \(uids)")
        
        IngredientService.fetchIngredients(for: uids) { ingredients in
            DispatchQueue.main.async {
                self.latestScanIngredients = ingredients
                print("Updated latestScanIngredients: \(ingredients.map { $0.name })")
            }
        }
    }

    
    
    
}
