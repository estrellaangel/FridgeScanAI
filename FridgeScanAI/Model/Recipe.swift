//
//  Recipie.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/20/25.
//
import SwiftUI

struct Recipe: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
    let usedIngredients: [DecodableIngredient]
    let missedIngredients: [DecodableIngredient]
    let unusedIngredients: [DecodableIngredient]
    
    let fullIngredients: [DecodableIngredient]?
    
    let sourceName: String?
    let sourceUrl: String?
    let spoonacularSourceUrl: String?
    let healthScore: Double?
    let readyInMinutes: Int?
    let servings: Int?
    let instructions: String?
    let summary: String?
    let dishTypes: [String]?
    
    var imageView: some View {
        AsyncImage(url: URL(string: image)) { phase in
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

//    var imageView: some View {
//        AsyncImage(url: URL(string: image)) { phase in
//            switch phase {
//            case .empty:
//                ProgressView()
//            case .success(let image):
//                image
//                    .resizable()
//                    .scaledToFill() // zoom and crop to fit square
//            case .failure:
//                Image(systemName: "photo")
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(.gray)
//            @unknown default:
//                EmptyView()
//            }
//        }
//    }
    
//EXAMPLE OF CALL FOR STRUCTURE
//        {
//            "id": 73420, ✅
//            "image": "https://img.spoonacular.com/recipes/73420-312x231.jpg", ✅
//            "imageType": "jpg",
//            "likes": 0,
//            "missedIngredientCount": 3,
//            "missedIngredients": [DecodableIngredient], ✅
//            "title": "Apple Or Peach Strudel", ✅
//            "unusedIngredients": [DecodableIngredient], ✅
//            "usedIngredientCount": 1,
//            "usedIngredients": [DecodableIngredient], ✅
//        },
//        {
//            "id": 632660,
//            "image": "https://img.spoonacular.com/recipes/632660-312x231.jpg",
//            "imageType": "jpg",
//            "likes": 3,
//            "missedIngredientCount": 4,
//            "missedIngredients": [DecodableIngredient],
//            "title": "Apricot Glazed Apple Tart",
//            "unusedIngredients": [DecodableIngredient],
//            "usedIngredientCount": 0,
//            "usedIngredients": []
//        }
    
    
}
