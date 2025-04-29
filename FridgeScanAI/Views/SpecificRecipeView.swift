//
//  SpecificRecipeView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/25/25.
//

import SwiftUI


struct SpecificRecipeView: View {
    let recipe: Recipe
    
    @StateObject private var scanSession = ScanSessionViewModel()
    
    var combinedIngredients: [DecodableIngredient] {
        recipe.usedIngredients + recipe.missedIngredients
    }
    
    var body: some View {
        VStack {
            Text(recipe.title)
                .font(.title2)
                .bold()

            List {
                Section(header: Text("Ingredients Needed").font(.title3).bold().foregroundColor(.white)) {
                    ForEach(combinedIngredients, id: \.id) { ingredient in
                        HStack {
                            Button(action: {
                                scanSession.toggleDetectedIngredient(for: ingredient)
                            }) {
                                Image(systemName: (scanSession.matchesDetectedIngredient(ingredientOriginal: ingredient.original)) ? "checkmark.square" : "square")
                                    .foregroundColor(.blue)
                            }

                            Text(ingredient.original)
                                .strikethrough(scanSession.matchesDetectedIngredient(ingredientOriginal: ingredient.original))
                                .foregroundColor(
                                    scanSession.matchesDetectedIngredient(ingredientOriginal: ingredient.original)
                                    ? .secondary
                                    : .primary
                                )
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
