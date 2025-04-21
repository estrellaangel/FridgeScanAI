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
    
    @State private var isUploading = true
    @State private var uploadStatusMessage = "Uploading scan..."
    
    var body: some View {
        VStack(spacing: 20) {
            Text(uploadStatusMessage)
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
                scanSession.setScan(from: snapshot) // update in-memory
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
