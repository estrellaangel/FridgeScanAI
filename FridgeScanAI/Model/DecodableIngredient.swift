//
//  DecodableIngredient.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/22/25.
//

import SwiftUI

struct DecodableIngredient: Decodable, Identifiable {
    let id: Int //id in api
    let image: String //url of image
    let name: String //name of ingredient
    let original: String //name of ingredient with amount
    
    let aisle: String?
    let amount: Double
    let consistency: String?
    let unit: String?

    var imageView: some View {
        AsyncImage(url: URL(string: image)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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
    
    //EXAMPLE 1 INGREDIENT INFO
    //    "aisle": "Baking",
    //    "amount": 1.0,
    //    "id": 18371,
    //    "image": "https://img.spoonacular.com/ingredients_100x100/white-powder.jpg",
    //    "meta": [],
    //    "name": "baking powder",
    //    "original": "1 tsp baking powder",
    //    "originalName": "baking powder",
    //    "unit": "tsp",
    //    "unitLong": "teaspoon",
    //    "unitShort": "tsp"
    
    //EXAMPLE 2
    //    "aisle": "Milk, Eggs, Other Dairy",
    //    "amount": 1.5,
    //    "extendedName": "unsalted butter",
    //    "id": 1001,
    //    "image": "https://img.spoonacular.com/ingredients_100x100/butter-sliced.jpg",
    //    "meta": [
    //      "unsalted",
    //      "cold"
    //    ],
    //    "name": "butter",
    //    "original": "1 1/2 sticks cold unsalted butter cold unsalted butter<",
    //    "originalName": "cold unsalted butter cold unsalted butter<",
    //    "unit": "sticks",
    //    "unitLong": "sticks",
    //    "unitShort": "sticks"

}
