//
//  ShoppingListView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI

struct ShoppingListView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Items missing from fridge")
                List {
                    // TODO: Add in the list of current recipes
                }
                
            }
            .padding()
            .navigationTitle("Shopping List")
        }
    }
}

#Preview {
    ShoppingListView()
}
