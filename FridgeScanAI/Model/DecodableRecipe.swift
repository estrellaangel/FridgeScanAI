//
//  DecodableRecipe.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/25/25.
//

import Foundation

struct DetailedRecipe: Decodable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let sourceName: String?
    let sourceUrl: String?
    let spoonacularSourceUrl: String?
    let healthScore: Double?
    let readyInMinutes: Int?
    let servings: Int?
    let instructions: String?
    let summary: String?
    let extendedIngredients: [DecodableIngredient]
    let dishTypes: [String]
}
