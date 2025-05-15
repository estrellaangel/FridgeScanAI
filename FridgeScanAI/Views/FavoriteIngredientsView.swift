//
//  FavoriteIngredientsView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/17/25.
//


import SwiftUI
import SwiftData

struct FavoriteIngredientsView: View {
    @StateObject private var viewModel = FavoriteIngredientsViewModel()
    @State private var newIngredient = ""
    @EnvironmentObject var scanSession: ScanSessionViewModel
    @EnvironmentObject var shoppingListVM: ShoppingListViewModel

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(shoppingListVM.favoriteBasedItems, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete(perform: delete)
                }

                HStack {
                    TextField("Add new favorite", text: $newIngredient)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Add") {
                        let trimmed = newIngredient.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.addIngredient(trimmed, shoppingListVM: shoppingListVM)
                        newIngredient = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Favorite Ingredients")
            .onAppear {
                viewModel.fetchFavorites(shoppingListVM: shoppingListVM)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        viewModel.deleteIngredient(at: offsets, shoppingListVM: shoppingListVM)
    }
}
