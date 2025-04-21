//
//  recipeGenerator.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/20/25.
//

import Foundation

func fetchRecipes(using ingredients: [String], completion: @escaping ([Recipe]?) -> Void) {
//    let apiKey = "YOUR_API_KEY"
//    let ingredientsQuery = ingredients.joined(separator: ",")
//    let number = 5 // Number of recipes to return
//    let ranking = 1 // Maximize used ingredients
//    let ignorePantry = true
//
//    // URL encode the ingredients
//    guard let encodedIngredients = ingredientsQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//          let url = URL(string: "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(encodedIngredients)&number=\(number)&ranking=\(ranking)&ignorePantry=\(ignorePantry)&apiKey=\(apiKey)") else {
//        print("Invalid URL")
//        completion(nil)
//        return
//    }
//
//    // Create the URL request
//    let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        guard let data = data, error == nil else {
//            print("Error fetching recipes: \(error?.localizedDescription ?? "Unknown error")")
//            completion(nil)
//            return
//        }
//
//        // Decode the JSON response
//        do {
//            let recipes = try JSONDecoder().decode([Recipe].self, from: data)
//            completion(recipes)
//        } catch {
//            print("Error decoding JSON: \(error.localizedDescription)")
//            completion(nil)
//        }
//    }
//
//    task.resume()
}
