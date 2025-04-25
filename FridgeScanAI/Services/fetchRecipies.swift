//
//  recipeGenerator.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/20/25.
//

import Foundation

func fetchRecipes(using ingredients: [String], recipeVM: RecipeViewModel) {
    print("🧪 fetchRecipes called with: \(ingredients)")
    let apiKey = "fba461876e794e77979294d0e4d3a092"
    let ingredientsQuery = ingredients.joined(separator: ",")
    let number = 5
    let ranking = 1
    let ignorePantry = true

    guard let encodedIngredients = ingredientsQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(encodedIngredients)&number=\(number)&ranking=\(ranking)&ignorePantry=\(ignorePantry)&apiKey=\(apiKey)") else {
        print("Invalid URL")
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching recipes: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        do {
            let basicRecipes = try JSONDecoder().decode([Recipe].self, from: data)

            var fullRecipes: [Recipe] = []
            let group = DispatchGroup()

            for basic in basicRecipes {
                group.enter()
                fetchRecipeInfo(using: basic.id) { detailed in
                    if let detailed = detailed {
                        let fullIngredients = detailed.extendedIngredients.map { ing in
                            return DecodableIngredient(
                                id: ing.id,
                                image: ing.image,
                                name: ing.name,
                                original: ing.original,
                                aisle: ing.aisle,
                                amount: ing.amount,
                                consistency: ing.consistency,
                                unit: ing.unit
                            )
                        }

                        let full = Recipe(
                            id: detailed.id,
                            title: detailed.title,
                            image: detailed.image,
                            usedIngredients: basic.usedIngredients,
                            missedIngredients: basic.missedIngredients,
                            unusedIngredients: basic.unusedIngredients,
                            fullIngredients: fullIngredients, // ✅ Correct full ingredients here!
                            sourceName: detailed.sourceName,
                            sourceUrl: detailed.sourceUrl,
                            spoonacularSourceUrl: detailed.spoonacularSourceUrl,
                            healthScore: detailed.healthScore,
                            readyInMinutes: detailed.readyInMinutes,
                            servings: detailed.servings,
                            instructions: detailed.instructions,
                            summary: detailed.summary,
                            dishTypes: detailed.dishTypes
                        )
                        fullRecipes.append(full)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                recipeVM.updateRecipes(fullRecipes)
                print("✅ Fetched full recipe info for \(fullRecipes.count) recipes.")
            }

        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
        }
    }

    task.resume()
}



func fetchRecipeInfo(using recipeId: Int, completion: @escaping (DetailedRecipe?) -> Void) {
    let apiKey = "fba461876e794e77979294d0e4d3a092"
    
    guard let url = URL(string: "https://api.spoonacular.com/recipes/\(recipeId)/information?includeNutrition=false&apiKey=\(apiKey)") else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching detailed recipe: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        
        do {
            let decodedRecipe = try JSONDecoder().decode(DetailedRecipe.self, from: data)
            DispatchQueue.main.async {
                completion(decodedRecipe)
            }
        } catch {
            print("Error decoding detailed recipe: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    task.resume()
}
