//
//  TestDetectionResultView.swift
//  FridgeScanAI
//
//  Created by Beckham Le on 4/26/25.
//

import SwiftUI

struct TestDetectionResultView: View {
    let detections: [DetectionResult]

    var body: some View {
        List(detections, id: \.self.className) { detection in
            VStack(alignment: .leading) {
                Text("🍏 \(detection.className)")
                    .font(.headline)
                Text("Confidence: \(String(format: "%.2f", detection.score))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Detections")
    }
}
