//
//  ShoppingList.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import Foundation
import SwiftData

@Model
class ShoppingList: Identifiable {
    
    //ingredients found in fridge
    var ingredients = [Ingredient]()
    
    //initializer - this is how we create an instance of the shopping list
    init(){
        
    }
    
    func addIngredient(ingredient: Ingredient){
        ingredients.append(ingredient)
    }
    
    func removeIngredient(ingredient: Ingredient){
        //TODO: add in logic of removing an ingredient
    }
    
}
