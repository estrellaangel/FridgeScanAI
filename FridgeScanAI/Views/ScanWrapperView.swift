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

    var body: some View {
        ZStack {
            ScanView(isRecording: $isRecording, videoURL: $videoURL)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack(spacing: 20) {
                    Button(action: {
                        isRecording = true
                    }) {
                        Text("Start")
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    Button(action: {
                        isRecording = false
                    }) {
                        Text("Stop")
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}


