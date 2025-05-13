//
//  IngredientDetailsView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/19/25.
//

import SwiftUI

struct IngredientDetailsView: View {
    let ingredient: Ingredient
    
    var body: some View {
        
        VStack(alignment: .leading){
            ingredient.image
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(maxWidth: .infinity)
        
        Text(ingredient.name)
            .font(.headline)
            .lineLimit(2)
            
        }
        
        
    }
}
