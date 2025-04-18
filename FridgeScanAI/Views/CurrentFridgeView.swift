//
//  CurrentFridgeView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI
import SwiftData

struct CurrentFridgeView: View {
    @Binding var selectedTab: Tab
    
    //Get all ingredients
    @Query(
            filter: #Predicate<FridgeContents> { _ in true },
            sort: [SortDescriptor<FridgeContents>(\.date, order: .reverse)]
        ) private var fridgeContents: [FridgeContents]

        var latestIngredients: [Ingredient] {
            fridgeContents.first?.ingredients ?? []
        }
    
    
    var body: some View {
        
            VStack(alignment: .leading, spacing: 20) {
                
                //CURRENT FRIDGE
                
                    Text("Current Ingredients")
                        .bold()
                    
                    Text("These are the current ingredients")
                    
                    List(latestIngredients, id: \.id) { ingredient in
                        Text(ingredient.name)
                    }
            
                //CURRENT RECIPIES
                
                    Text("Current Recipes")
                        .bold()
                    
                    Text("These are the current recipes")
                    
                    List {
                        // TODO: Add in the list of current recipes
                    }
                
                Button("Go to Shopping Cart") {
                    selectedTab = .cart
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                
            }
            .padding()
            .navigationTitle("My Fridge")

    }
    
}

#Preview {
    CurrentFridgeView(selectedTab: .constant(.fridge))
}
