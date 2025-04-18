//
//  Ingredient.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import Foundation
import SwiftData

@Model
class Ingredient: Identifiable {
    
    //generates a unique id string
    var id: String = UUID().uuidString
    
    //empty string that user will upload their ingredient
    var name: String = ""
    
    //tracks last time was updated
    var lastUpdated: Date = Date()
    
    // amount eventually added in
    var amount: String = ""
    
    //so that in the data we dont loose count of ingredient
    var isHidden: Bool = false
    
    //initializer - this is how we create an instance of the ingredient
    init(name: String){
        self.name = name
    }
    
}
