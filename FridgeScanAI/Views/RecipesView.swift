import SwiftUI

struct RecipesView: View {
    
    @EnvironmentObject var scanSession: ScanSessionViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    @State private var lastFetchedScanID: String? = nil

    var body: some View {
        
        VStack {
            
            Text("Recipe Suggestions")
                .bold()
            
            if recipeVM.currentRecipes.isEmpty {
                Text("No recipes found yet.")
                    .foregroundColor(.gray)
            } else {
                List(recipeVM.currentRecipes) { recipe in
                    VStack(alignment: .leading, spacing: 16) {

                        RecipePageDetailView(recipe:recipe)
                        
                    }
                }
            }
        }
        .onAppear {

            recipeVM.loadRecipesFromFirebase()

        }
        .navigationTitle("Recommended Recipes")
    }
}
