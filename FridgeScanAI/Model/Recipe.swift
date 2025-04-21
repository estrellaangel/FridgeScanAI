//
//  Recipie.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/20/25.
//

import SwiftUI

struct Recipe: Identifiable {
    
    //id of recipe
    var id: Int
    
    //title of recipe
    var title: String
    
    //url of image
    var urlOfPhoto: String
    
    var usedIngredients: [Ingredient]
    
    var missedIngredients: [Ingredient]
    
    var unusedIngredients: [Ingredient]
    
    var image: some View {
        AsyncImage(url: URL(string: urlOfPhoto)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit) // 🛠 specify ContentMode explicitly
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
    
}
