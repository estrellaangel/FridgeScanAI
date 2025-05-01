//
//  DetectedItemsView.swift
//  FridgeScanAI
//
//  Created by Beckham Le on 4/27/25.
//

import SwiftUI

struct DetectedItemsView: View {
    let detections: [DetectionResult]

    var body: some View {
        List(detections, id: \.self.className) { detection in
            VStack(alignment: .leading, spacing: 6) {
                Text("🍏 \(detection.className)")
                    .font(.headline)
                Text("Confidence: \(String(format: "%.2f", detection.score))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Detected Items")
    }
}
