import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject var scanSession: ScanSessionViewModel
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var newItem = ""

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    
                    // Show ONLY unchecked favorite items
                    ForEach(viewModel.favoriteBasedItems.filter { !viewModel.isChecked($0) }, id: \.self) { item in
                        shoppingItemRow(item: item)
                    }
                    
                    
                    // Show ALL manual items
                    ForEach(viewModel.manualItems, id: \.self) { item in
                        shoppingItemRow(item: item)
                    }
                    
                    
                }
                
                HStack {
                    TextField("Add item", text: $newItem)
                        .textFieldStyle(.roundedBorder)

                    Button("Add") {
                        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.addManualItem(trimmed)
                        newItem = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Shopping List")
            .onAppear {
                viewModel.fetchShoppingList(scanSessionVM: scanSession)
            }
        }
    }

    private func shoppingItemRow(item: String) -> some View {
        HStack {
            Button(action: {
                viewModel.toggleChecked(for: item)
            }) {
                Image(systemName: viewModel.isChecked(item) ? "checkmark.square" : "square")
                    .foregroundColor(.blue)
            }

            Text(item)
                .strikethrough(viewModel.isChecked(item))
                .foregroundColor(viewModel.isChecked(item) ? .secondary : .primary)
        }
    }
}
