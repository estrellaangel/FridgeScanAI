import Foundation
import FirebaseAuth
import FirebaseFirestore

class FavoriteIngredientsViewModel: ObservableObject {
    private let db = Firestore.firestore()

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    // No need for a local favoriteIngredients array anymore!

    // MARK: - Fetch Favorites and Update ShoppingListViewModel
    func fetchFavorites(shoppingListVM: ShoppingListViewModel) {
        guard let userID else { return }

        let favoriteRef = db.collection("users").document(userID).collection("shoppingList").document("favoriteIngredients")

        favoriteRef.getDocument { snapshot, error in
            if let favoriteData = snapshot?.data(),
               let favorites = favoriteData["items"] as? [String] {
                DispatchQueue.main.async {
                    shoppingListVM.favoriteBasedItems = favorites
                }
            } else {
                print("Couldn't load favorites: \(error?.localizedDescription ?? "No data")")
            }
        }
    }

    // MARK: - Add a Favorite Ingredient
    func addIngredient(_ name: String, shoppingListVM: ShoppingListViewModel) {
        guard let userID else { return }

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if !shoppingListVM.favoriteBasedItems.contains(trimmed) {
            shoppingListVM.favoriteBasedItems.append(trimmed)

            db.collection("users").document(userID).collection("shoppingList").document("favoriteIngredients")
                .setData(["items": shoppingListVM.favoriteBasedItems], merge: true)
        }
    }

    // MARK: - Delete a Favorite Ingredient
    func deleteIngredient(at offsets: IndexSet, shoppingListVM: ShoppingListViewModel) {
        guard let userID else { return }

        shoppingListVM.favoriteBasedItems.remove(atOffsets: offsets)

        db.collection("users").document(userID).collection("shoppingList").document("favoriteIngredients")
            .setData(["items": shoppingListVM.favoriteBasedItems], merge: true)
    }
}
