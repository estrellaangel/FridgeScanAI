//
//  ScanWrapperView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/17/25.
//

import SwiftUI

struct ScanViewWrapper: View {
    @Binding var isRecording: Bool
    @Binding var videoURL: URL?
    @Binding var didFinishRecording: Bool
    
    
    //ANONYMOUS USER USED FOR STORING SCANS + HAVING HISTORY SCANS
    @Binding var userID: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScanView(isRecording: $isRecording, videoURL: $videoURL, didFinishRecording: $didFinishRecording)
                    .ignoresSafeArea(edges: [.top])

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
            // Modern navigationDestination modifier
            .navigationDestination(isPresented: $didFinishRecording) {
                ScanResultView(videoURL: videoURL) {
                    // Reset state when leaving result screen
                    isRecording = false
                    didFinishRecording = true
                }
            }
        }
    }
}
