//
//  ScanResultsView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel & Beckham Le
//

/*
 
 - This view is presented after a scan finishes recording.
 - It handles uploading the scan, updating recipes, analyzing the video locally, and updating app state
 
 */

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ScanResultsView: View {
    let videoURL: URL?  // url of fridge scan video file just recorded
    @Binding var selectedTab: Tab   // allows this view to switch views
    var onDismiss: () -> Void   // closure to cleanly exit this view after processing

    // SHARED VIEW MODELS
    @EnvironmentObject var scanSession: ScanSessionViewModel
    @EnvironmentObject var favoriteVM: FavoriteIngredientsViewModel
    @EnvironmentObject var shoppingListVM: ShoppingListViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel

    // PROGRESS MESSAGES AND UI STATE
    @State private var uploadStatusMessage  = "Uploading scan..."
    @State private var uploadRecipeMessage  = "Updating possible recipes..."
    @State private var isAnalyzing           = false
    @State private var isCompleted           = false

    // SHOWS UPLOAD AND RECIPE STATUS MESSAGES
    var body: some View {
        VStack(spacing: 20) {
            Text(uploadStatusMessage)
                .font(.title2)
            Text(uploadRecipeMessage)
                .font(.title2)
            if isAnalyzing {
                ProgressView("Analyzing scan locally…")
                    .padding(.top)
            }
            if isCompleted {
                Text("All done!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .onAppear {
            startPipeline()
        }
    }

    // begins the pipeline by uploading the scan
    private func startPipeline() {
        uploadScan()
    }

    // handles the process of uploading scans
    private func uploadScan() {
        guard let url = videoURL else {
            uploadStatusMessage = "Missing video"
            return
        }

        uploadStatusMessage = "Uploading scan…"
        ScanUploadService.upload(videoURL: url) { result in
            switch result {
            case .success(let snapshot):
                DispatchQueue.main.async {
                    uploadStatusMessage = "Scan uploaded successfully"
                    uploadRecipeMessage = "Updating recipes…"

                    // Firebase + recipe update
                    scanSession.setScan(
                        from: snapshot,
                        favoriteVM: favoriteVM,
                        shoppingListVM: shoppingListVM
                    ) {
                        let names = scanSession.latestScanIngredients.map { $0.name }
                        fetchRecipes(using: names, recipeVM: recipeVM)
                        DispatchQueue.main.async {
                            uploadRecipeMessage = "Recipes updated"
                            // Kick off on‑device object analysis
                            analyzeVideo()
                        }
                        
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    uploadStatusMessage = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }

    // handles the object analysis process in this view
    private func analyzeVideo() {
        //Prevents re-analysis and ensures a video is available
        guard let url = videoURL, !isAnalyzing else { return }
        isAnalyzing = true

        // collect unique labels across all frames
        var foundLabels = Set<String>()

        guard let detector = VideoObjectDetector() else {
            uploadStatusMessage = "Failed to initialize detector"
            isAnalyzing = false
            return
        }

        // analyzes video frame by frame
        detector.process(
            videoURL: url,
            frameHandler: { _, observations in
                observations
                    .compactMap { $0.labels.first?.identifier }
                    .forEach { foundLabels.insert($0) } //pulls top label and stores it
            },
            completion: {
                //Fetch full Ingredient objects with images
                let namesArray = Array(foundLabels)
                IngredientService.fetchIngredients(for: namesArray) { ingredients in
                    DispatchQueue.main.async {
                        scanSession.latestScanIngredients = ingredients
                        isAnalyzing = false
                        isCompleted = true
                        
                        //Uploads names of new current fridge items list to Firebase
                        let namesToSave = ingredients.map { $0.name }
                        scanSession.UploadDetectionList(names: namesToSave)

                        //After a brief pause, switch tabs & dismiss
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            selectedTab = .fridge
                            onDismiss()
                        }
                    }
                }
            }
        )
    }
}
