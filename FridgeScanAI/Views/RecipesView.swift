//
//  RecipesView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI

struct RecipesView: View {
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
            
                HStack{
                    Text("SEARCH BAR")
                    
                    Spacer()
                    
                    Button("Filter") {
                        //TODO: Add in filter logic
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                
                Text("These are the current recipes")
                List {
                    // TODO: Add in the list of current recipes
                }
                
            }
            .padding()
            .navigationTitle("Recipies")
        }
        
    }
}

#Preview {
    RecipesView()
}
