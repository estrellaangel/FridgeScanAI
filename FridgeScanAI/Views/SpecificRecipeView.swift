import SwiftUI

struct SpecificRecipeView: View {
    let recipe: Recipe

    @EnvironmentObject var scanSession: ScanSessionViewModel
    @EnvironmentObject var shoppingListVM: ShoppingListViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(recipe.title)
                    .font(.title2)
                    .bold()

                recipe.imageView
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)

                    ForEach(sortedIngredients(), id: \.id) { ingredient in
                        ingredientRow(ingredient)
                    }
                }

                recipeSummaryDisplay()
            }
            .padding()
        }
        .onAppear {
            shoppingListVM.fetchShoppingList(scanSessionVM: scanSession)
        }
        .navigationTitle("Recipe Details")
    }

    private func sortedIngredients() -> [DecodableIngredient] {
        guard let ingredients = recipe.fullIngredients else { return [] }

        let scannedNames = Set(scanSession.latestScanIngredients.map { $0.name.lowercased() })

        func isScanned(_ ing: DecodableIngredient) -> Bool {
            scannedNames.contains(ing.name.lowercased())
        }

        // Only sort ingredients that were scanned preserve original order for the rest
        let scanned = ingredients.filter { isScanned($0) }
        let unscanned = ingredients.filter { !isScanned($0) }

        return scanned + unscanned
    }

    private func statusLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .bold()
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .foregroundColor(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }


    private func ingredientRow(_ ingredient: DecodableIngredient) -> some View {
        let isScanned = scanSession.latestScanIngredients.contains {
            $0.name.lowercased() == ingredient.name.lowercased()
        }
        let isInShoppingList = shoppingListVM.manualItems.contains {
            looselyMatches($0, ingredient.name)
        } || shoppingListVM.favoriteBasedItems.contains {
            !shoppingListVM.isChecked($0) && looselyMatches($0, ingredient.name)
        }

        return HStack {
            Text("\(formattedAmount(ingredient.amount))\(ingredient.unit.map { " \($0)" } ?? "") \(ingredient.name)")
                .strikethrough((isScanned || isInShoppingList))
                .foregroundColor((isScanned || isInShoppingList) ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)  // Ensures label stays aligned and doesn't get squeezed

            if isScanned {
                statusLabel("SCANNED", color: .blue)
            } else if isInShoppingList {
                statusLabel("IN LIST", color: .orange)
            } else {
                Button(action: {
                    shoppingListVM.addManualItem(ingredient.name)
                }) {
                    Text("ADD")
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.green.opacity(0.85))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }



    private func recipeSummaryDisplay() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary")
                .font(.title3)
                .bold()
                .foregroundColor(.white)

            if let summary = recipe.summary, !summary.isEmpty {
                Text(cleanSummaryHTML(summary))
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Could not find recipe summary")
                    .foregroundColor(.secondary)
            }

        }
    }

    private func formattedAmount(_ amount: Double) -> String {
        amount.truncatingRemainder(dividingBy: 1) == 0 ?
            String(Int(amount)) :
            String(format: "%.2f", amount)
    }
    
    func cleanSummaryHTML(_ html: String) -> String {
        // Remove <b>, </b>, <i>, </i>
        var cleaned = html
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
            .replacingOccurrences(of: "<i>", with: "")
            .replacingOccurrences(of: "</i>", with: "")
            .replacingOccurrences(of: "</a>", with: "")
        
        cleaned = cleaned.replacingOccurrences(of: "<a[^>].*?>", with: "", options: .regularExpression)

        return cleaned
    }
    
    func looselyMatches(_ item: String, _ ingredient: String) -> Bool {
        let itemLower = item.lowercased()
        let ingredientLower = ingredient.lowercased()

        return itemLower == ingredientLower ||
               itemLower == ingredientLower + "s" ||
               itemLower + "s" == ingredientLower
    }

    
}
