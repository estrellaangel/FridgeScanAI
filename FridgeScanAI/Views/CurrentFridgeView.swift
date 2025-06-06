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
    @EnvironmentObject var scanSession: ScanSessionViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    var body: some View {
        
            VStack(alignment: .leading, spacing: 20) {
                
                //CURRENT FRIDGE
                
                    Text("Current Ingredients")
                        .bold()
                
                    if scanSession.latestScanIngredients.isEmpty {
                        Text("No ingredients detected yet.")
                            .foregroundColor(.secondary)
                    } else {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(scanSession.latestScanIngredients) { ingredient in
                                    IngredientDetailsView(ingredient: ingredient)
                                        .frame(width: 140)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 200)
                    }
                    
                Spacer()
                Spacer()
                
                Button("Go to Shopping List") {
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
