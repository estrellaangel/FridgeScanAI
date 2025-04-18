//
//  FridgeContents.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import Foundation
import SwiftData

@Model
class FridgeContents : Identifiable {
    
    //ID string
    var id: String = UUID().uuidString
    
    //date fridge contents were generated (scanned)
    var date: Date = Date()
    
    //ingredients found in fridge
    var ingredients = [Ingredient]()
    
    //initializer - this is how we create an instance of the fridgescan
    init(ingredients: [Ingredient]){
        self.ingredients = ingredients
    }
    
}
