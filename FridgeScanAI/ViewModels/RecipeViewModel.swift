//
//  RecipeViewModel.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class RecipeViewModel: ObservableObject {
    @Published var currentRecipes: [Recipe] = []
    private let db = Firestore.firestore()

    func updateRecipes(_ recipes: [Recipe]) {
        self.currentRecipes = recipes
        saveRecipesToFirebase()
    }

    private func saveRecipesToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No user ID found")
            return
        }

        var recipeDictArray: [[String: Any]] = []

        for recipe in currentRecipes {
            let usedIngredients = recipe.usedIngredients.map { ing in
                return [
                    "id": ing.id,
                    "name": ing.name,
                    "original": ing.original,
                    "image": ing.image,
                    "aisle": ing.aisle ?? "",
                    "amount": ing.amount,
                    "consistency": ing.consistency ?? "",
                    "unit": ing.unit ?? ""
                ]
            }
            
            let missedIngredients = recipe.missedIngredients.map { ing in
                return [
                    "id": ing.id,
                    "name": ing.name,
                    "original": ing.original,
                    "image": ing.image,
                    "aisle": ing.aisle ?? "",
                    "amount": ing.amount,
                    "consistency": ing.consistency ?? "",
                    "unit": ing.unit ?? ""
                ]
            }
            
            let unusedIngredients = recipe.unusedIngredients.map { ing in
                return [
                    "id": ing.id,
                    "name": ing.name,
                    "original": ing.original,
                    "image": ing.image,
                    "aisle": ing.aisle ?? "",
                    "amount": ing.amount,
                    "consistency": ing.consistency ?? "",
                    "unit": ing.unit ?? ""
                ]
            }
            
            let fullIngredients = recipe.fullIngredients?.map { ing in
                return [
                    "id": ing.id,
                    "name": ing.name,
                    "original": ing.original,
                    "image": ing.image,
                    "aisle": ing.aisle ?? "",
                    "amount": ing.amount,
                    "consistency": ing.consistency ?? "",
                    "unit": ing.unit ?? ""
                ]
            } ?? []

            let recipeDict: [String: Any] = [
                "id": recipe.id,
                "title": recipe.title,
                "image": recipe.image,
                "usedIngredients": usedIngredients,
                "missedIngredients": missedIngredients,
                "unusedIngredients": unusedIngredients,
                "fullIngredients": fullIngredients,
                "sourceName": recipe.sourceName ?? "",
                "sourceUrl": recipe.sourceUrl ?? "",
                "spoonacularSourceUrl": recipe.spoonacularSourceUrl ?? "",
                "healthScore": recipe.healthScore ?? 0.0,
                "readyInMinutes": recipe.readyInMinutes ?? 0,
                "servings": recipe.servings ?? 0,
                "instructions": recipe.instructions ?? "",
                "summary": recipe.summary ?? "",
                "dishTypes": recipe.dishTypes ?? []
            ]

            recipeDictArray.append(recipeDict)
        }

        db.collection("users").document(userID).collection("currentRecipes").document("main")
          .setData(["items": recipeDictArray], merge: true) { error in
            if let error = error {
                print("❌ Failed to upload recipes: \(error)")
            } else {
                print("✅ Recipes successfully uploaded to Firebase.")
            }
        }
    }

    func loadRecipesFromFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No user ID found")
            return
        }

        db.collection("users").document(userID).collection("currentRecipes").document("main")
          .getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let storedRecipes = data["items"] as? [[String: Any]] {
                
                let decoded: [Recipe] = storedRecipes.compactMap { dict in
                    guard let id = dict["id"] as? Int,
                          let title = dict["title"] as? String,
                          let image = dict["image"] as? String,
                          let used = dict["usedIngredients"] as? [[String: Any]],
                          let missed = dict["missedIngredients"] as? [[String: Any]],
                          let unused = dict["unusedIngredients"] as? [[String: Any]] else {
                        return nil
                    }
                    
                    // ✅ Correct way: pull fullIngredients separately after guard
                    let full = dict["fullIngredients"] as? [[String: Any]] ?? []

                    func decode(_ arr: [[String: Any]]) -> [DecodableIngredient] {
                        return arr.compactMap { ing in
                            guard let id = ing["id"] as? Int,
                                  let name = ing["name"] as? String,
                                  let original = ing["original"] as? String,
                                  let image = ing["image"] as? String else {
                                return nil
                            }
                            return DecodableIngredient(
                                id: id,
                                image: image,
                                name: name,
                                original: original,
                                aisle: ing["aisle"] as? String,
                                amount: ing["amount"] as? Double ?? 0.0,
                                consistency: ing["consistency"] as? String,
                                unit: ing["unit"] as? String
                            )
                        }
                    }

                    return Recipe(
                        id: id,
                        title: title,
                        image: image,
                        usedIngredients: decode(used),
                        missedIngredients: decode(missed),
                        unusedIngredients: decode(unused),
                        fullIngredients: decode(full), // ✅ decode and assign fullIngredients properly!
                        sourceName: dict["sourceName"] as? String,
                        sourceUrl: dict["sourceUrl"] as? String,
                        spoonacularSourceUrl: dict["spoonacularSourceUrl"] as? String,
                        healthScore: dict["healthScore"] as? Double,
                        readyInMinutes: dict["readyInMinutes"] as? Int,
                        servings: dict["servings"] as? Int,
                        instructions: dict["instructions"] as? String,
                        summary: dict["summary"] as? String,
                        dishTypes: dict["dishTypes"] as? [String]
                    )
                }

                DispatchQueue.main.async {
                    self.currentRecipes = decoded
                }
            } else {
                print("⚠️ No stored recipes found or error: \(error?.localizedDescription ?? "Unknown")")
            }
        }
    }

    

}
