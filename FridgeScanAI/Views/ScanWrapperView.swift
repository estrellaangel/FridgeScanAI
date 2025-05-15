//
//  ScanWrapperView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/17/25 & Beckham Le.
//

import SwiftUI

struct ScanViewWrapper: View {
    @Binding var isRecording: Bool  // Indicates if a recording is currently happening
    @Binding var videoURL: URL? // Holds the recorded video’s URL after scanning
    @Binding var didFinishRecording: Bool   // Indicates when a recording is done
    @Binding var userID: String // Identifies the anonymous user for saving scan history
    @Binding var selectedTab: Tab   //Used for switching from scan results page to current fridge tab
    
    // Manages navigation state and allows navigation to other screens
    var body: some View {
        NavigationStack {
            // Layers views on top of each other (ideal for placing overlays)
            ZStack {
                // Live camera view
                ScanView(isRecording: $isRecording, videoURL: $videoURL, didFinishRecording: $didFinishRecording)
                    .ignoresSafeArea(edges: [.top])
                //Overlay when not recording
                if !isRecording {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Text("Ready to scan your fridge.")
                            .font(.title2)
                            .foregroundColor(.white)
                            .bold()
                        Text("Tap 'Start' to begin recording.")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline)
                    }
                }
                // Start/Stop Button
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: {
                            if !isRecording {
                                // Starting a new recording
                                videoURL = nil

                            }
                            isRecording.toggle()
                        }) {
                            Text(isRecording ? "Stop" : "Start")
                                .padding()
                                .background((isRecording ? Color.red : Color.green).opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            // When done recording, switches to ScanResultsView page
            .navigationDestination(isPresented: $didFinishRecording) {
                ScanResultsView(
                    videoURL: videoURL, // passes video file url to new page
                    selectedTab: $selectedTab,  // name of page transitioning to
                    onDismiss: {
                        // Reset state when leaving result screen
                        isRecording = false
                        didFinishRecording = false
                    }
                )
            }
        }
    }
}
