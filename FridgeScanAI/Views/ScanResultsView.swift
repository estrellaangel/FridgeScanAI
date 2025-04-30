//
//  ScanResultsView.swift
//  FridgeScanAI
//


import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ScanResultView: View {
    let videoURL: URL?
    var onDismiss: () -> Void

    @EnvironmentObject var scanSession: ScanSessionViewModel
    
    //ADDED BY SABRINA
    @EnvironmentObject var favoriteVM: FavoriteIngredientsViewModel
    @EnvironmentObject var shoppingListVM: ShoppingListViewModel
    
    //FOR RECIPES
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    @State private var isUploading = true
    @State private var uploadStatusMessage = "Uploading scan..."
    @State private var uploadRecipeMessage = "Updating Possible Recipes ..."
    
    var body: some View {
        VStack(spacing: 20) {
            Text(uploadStatusMessage)
                .font(.title2)
                .padding()
            Text(uploadRecipeMessage)
                .font(.title2)
                .padding()
        }
        .padding()
        .onAppear {
            if isUploading {
                uploadScan()
            }
        }
    }

    func uploadScan() {
        guard let videoURL = videoURL else {
            uploadStatusMessage = "Missing video"
            return
        }

        ScanUploadService.upload(videoURL: videoURL) { result in
        switch result {
        case .success(let snapshot):
            DispatchQueue.main.async {
                scanSession.setScan(from: snapshot, favoriteVM: favoriteVM, shoppingListVM: shoppingListVM) {
                    
                    // Only fetch recipes after latestScanIngredients is ready
                    let names = scanSession.latestScanIngredients.map { $0.name }
                    fetchRecipes(using: names, recipeVM: recipeVM)
                    
                    uploadRecipeMessage = "Updated Recipes successfully"
                }
                
                uploadStatusMessage = "Scan uploaded successfully"
            }
        case .failure(let error):
            DispatchQueue.main.async {
                uploadStatusMessage = "Upload failed: \(error.localizedDescription)"
            }
        }

        isUploading = false
    }

    }
}
