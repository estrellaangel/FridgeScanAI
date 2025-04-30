//
//  ScanWrapperView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/17/25.
//

import SwiftUI
import AVFoundation

struct ScanWrapperView: View {
    @Binding var isRecording: Bool
    @Binding var videoURL: URL?
    @Binding var didFinishRecording: Bool
    @Binding var userID: String

    @State private var detections: [DetectionResult] = []
    @State private var showTestResults = false

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
            .onChange(of: didFinishRecording) { finished in
                if finished, let videoURL = videoURL {
                    analyzeRecordedVideo(url: videoURL)
                }
            }
            .navigationDestination(isPresented: $showTestResults) {
                DetectedItemsView(detections: detections)
            }
        }
    }

    private func analyzeRecordedVideo(url: URL) {
        FridgeScanModelService.shared.predictFromVideo(url: url) { results in
            DispatchQueue.main.async {
                detections = results
                showTestResults = true
            }
        }
    }
}
