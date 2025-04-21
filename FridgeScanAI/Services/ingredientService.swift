//
//  ingredientService.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/19/25.
//

import FirebaseFirestore

struct IngredientService {
    static func fetchIngredients(for uids: [String], completion: @escaping ([Ingredient]) -> Void) {
        let db = Firestore.firestore()
        
        guard !uids.isEmpty else {
            completion([])
            return
        }

        let chunkedUIDs = uids.chunked(into: 10)
        var allIngredients: [Ingredient] = []
        var finishedChunks = 0

        for chunk in chunkedUIDs {
            db.collection("ingredients")
                .whereField("name", in: chunk)
                .getDocuments { snapshot, error in
                    finishedChunks += 1
                    if let snapshot = snapshot {
                        for doc in snapshot.documents {
                            let data = doc.data()
                            if let name = data["name"] as? String,
                               let uid = data["uid"] as? String,
                               let imageURL = data["imageURL"] as? String {
                                allIngredients.append(Ingredient(name: name, uid: uid,  urlOfPhoto: imageURL))
                            }
                        }
                    }

                    if finishedChunks == chunkedUIDs.count {
                        DispatchQueue.main.async {
                            completion(allIngredients)
                        }
                    }
                }
        }
    }
}
