//
//  FavoriteIngredientsView.swift
//  FridgeScanAI
//
//  Created by Sabrina Farias on 4/21/25.
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
                    ForEach(viewModel.favoriteIngredients, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete(perform: delete)
                }

                HStack {
                    TextField("Add new favorite", text: $newIngredient)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        guard !newIngredient.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        viewModel.addIngredient(newIngredient, shoppingListVM: shoppingListVM, scanSessionVM: scanSession)
                        newIngredient = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Favorite Ingredients")
            .onAppear {
                viewModel.fetchFavorites(
                    shoppingListVM: shoppingListVM,
                    scanSessionVM: scanSession
                )
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteIngredient(at: index, shoppingListVM: shoppingListVM, scanSessionVM: scanSession)
        }
    }
}


#Preview {
    FavoriteIngredientsView()
        .environmentObject(ScanSessionViewModel())
}
