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
//
//import SwiftUI
//
//struct IngredientDetailsView: View {
//    let ingredient: Ingredient
//
//    var body: some View {
//        VStack(alignment: .center) {
//            ingredient.image
//                .resizable() // Ensure it's resizable
//                .scaledToFill() // Zooms in to fill the square
//                .frame(width: 100, height: 100) // Square shape
//                .clipped() // Crop any overflow
//                .background(Color.white)
//                .cornerRadius(12)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
//                )
//
//            Text(ingredient.name)
//                .font(.headline)
//                .foregroundColor(.primary)
//                .multilineTextAlignment(.center)
//                .lineLimit(2)
//                .frame(maxWidth: 100)
//        }
//        .padding(8)
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//    }
//}
