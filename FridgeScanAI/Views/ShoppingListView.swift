//
//  ShoppingListView.swift
//  FridgeScanAI
//
//  Created by Sabrina Farias 4/25.
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var newItem = ""
    @State private var checkedItems: [String: Bool] = [:]

    var body: some View {
        NavigationStack {
            
            // IF TIME: add in scanned items as already crossed off items
            
            VStack {
                List {
                    ForEach(viewModel.shoppingList, id: \.self) { item in
                        HStack {
                            Button(action: {
                                checkedItems[item]?.toggle()
                            }) {
                                Image(systemName: (checkedItems[item] ?? false) ? "checkmark.square" : "square")
                                    .foregroundColor(.blue)
                            }

                            Text(item)
                                .strikethrough(checkedItems[item] ?? false)
                                .foregroundColor((checkedItems[item] ?? false) ? .secondary : .primary)
                        }
                        .onAppear {
                            // Initialize checkbox state if it's new
                            if checkedItems[item] == nil {
                                checkedItems[item] = false
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteItem)
                }

                HStack {
                    TextField("Add item", text: $newItem)
                        .textFieldStyle(.roundedBorder)

                    Button("Add") {
                        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.addItem(trimmed)
                        checkedItems[trimmed] = false
                        newItem = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Shopping List")
            .onAppear {
                viewModel.fetchShoppingList()
                
                // Reset checkboxes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    for item in viewModel.shoppingList {
                        checkedItems[item] = false
                    }
                }
            }
        }
    }
}
