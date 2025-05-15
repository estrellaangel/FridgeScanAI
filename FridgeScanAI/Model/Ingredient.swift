//
//  Ingredient.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Ingredient: Identifiable {
    
    //generates a unique id string
    var internalId: String = UUID().uuidString
    
    //gets ingredientid (makes it distinquishable in database
    var uid: String = ""
    
    //empty string that user will upload their ingredient
    var name: String = ""
    
    // amount eventually added in
    var amount: String = ""
    
    // url of photo
    var urlOfPhoto: String = ""
    
    //initializer - this is how we create an instance of the ingredient
    init(name: String, uid: String, urlOfPhoto: String){
        self.name = name
        self.uid = uid
        self.urlOfPhoto = urlOfPhoto
    }
    
    var image: some View {
        AsyncImage(url: URL(string: urlOfPhoto)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit) //specify ContentMode explicitly
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
