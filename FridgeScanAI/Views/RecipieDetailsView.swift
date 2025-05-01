//
//  RecipieDetailsView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/21/25.
//

//import SwiftUI
//
//struct RecipieDetailsView: View {
//    let recipe: Recipe
//    
//    var body: some View {
//        
//        VStack(alignment: .leading){
//            recipe.imageView
//            .aspectRatio(1, contentMode: .fit)
//            .clipShape(RoundedRectangle(cornerRadius: 18))
//            .frame(maxWidth: .infinity)
//        
//        Text(recipe.title)
//            .font(.headline)
//            .lineLimit(2)
//            
//        }
//        
//        
//    }
//}
//
//#Preview {
//    RecipieDetailsView()
//}

import SwiftUI

struct RecipieDetailsView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .center) {
            
            VStack(alignment: .leading){
                recipe.imageView
//                .aspectRatio(1, contentMode: .fit)
//                .clipShape(RoundedRectangle(cornerRadius: 18))
//                .frame(maxWidth: .infinity)
            
            Text(recipe.title)
                .font(.headline)
                .lineLimit(2)
                
            }
            
        }
    }
}
