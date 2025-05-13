//
//  FridgeScanModelService.swift
//  FridgeScanAI
//
//  Created by Beckham Le on 4/25/25.
//

import CoreML
import CoreVideo
import UIKit
import AVFoundation

struct DetectionResult {
    let className: String
    let boundingBox: CGRect
    let score: Float
}

class FridgeScanModelService {
    static let shared = FridgeScanModelService()

    private let model: MLModel

    private init() {
        // Load fridge_scan_ai.mlpackage
        guard let url = Bundle.main.url(forResource: "fridge_scan_ai", withExtension: "mlmodelc"),
              let loadedModel = try? MLModel(contentsOf: url) else {
            fatalError("Failed to load fridge_scan_ai.mlpackage")
        }
        self.model = loadedModel

        print("CoreML model loaded successfully!")
    }

    func predict(pixelBuffer: CVPixelBuffer) -> [DetectionResult] {
        // Resize the image
        guard let resizedBuffer = pixelBuffer.resize(to: CGSize(width: 640, height: 640)) else {
            print("Failed to resize frame")
            return []
        }

        // Convert to MLMultiArray
        guard let inputArray = resizedBuffer.toMultiArray() else {
            print("Failed to convert to MLMultiArray")
            return []
        }

        do {
            let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [
                "serving_default_input": MLFeatureValue(multiArray: inputArray)
            ])

            let prediction = try model.prediction(from: inputFeatures)

            // Parse outputs
            guard
                let boxesArray = prediction.featureValue(for: "TFLite_Detection_PostProcess0")?.multiArrayValue,
                let classesArray = prediction.featureValue(for: "TFLite_Detection_PostProcess1")?.multiArrayValue,
                let scoresArray = prediction.featureValue(for: "TFLite_Detection_PostProcess2")?.multiArrayValue,
                let numDetectionsRaw = prediction.featureValue(for: "TFLite_Detection_PostProcess3")?.multiArrayValue
            else {
                print("Could not extract outputs properly")
                return []
            }

            // Check and reshape numDetectionsArray properly
            let numDetectionsArray: MLMultiArray
            if numDetectionsRaw.shape.count == 2, numDetectionsRaw.shape[0].intValue == 1 {
                // (1, 100) → we assume first row
                let reshaped = try? MLMultiArray(shape: [numDetectionsRaw.shape[1]], dataType: numDetectionsRaw.dataType)
                for i in 0..<numDetectionsRaw.shape[1].intValue {
                    reshaped?[i] = numDetectionsRaw[[0, NSNumber(value: i)]]
                }
                if let reshaped = reshaped {
                    numDetectionsArray = reshaped
                } else {
                    print("Failed to reshape numDetections array")
                    return []
                }
            } else {
                numDetectionsArray = numDetectionsRaw
            }

            // Parse detections
            return parseDetections(
                boxes: boxesArray,
                classes: classesArray,
                scores: scoresArray,
                numDetections: numDetectionsArray
            )

        } catch {
            print("Inference failed: \(error)")
            return []
        }
    }

    private func parseDetections(
        boxes: MLMultiArray,
        classes: MLMultiArray,
        scores: MLMultiArray,
        numDetections: MLMultiArray
    ) -> [DetectionResult] {
        let detectionCount = Int(truncating: numDetections[0])

        var results: [DetectionResult] = []

        for i in 0..<detectionCount {
            let score = scores[i].floatValue
            if score < 0.5 { continue } // You can adjust this threshold

            let ymin = boxes[i * 4 + 0].floatValue
            let xmin = boxes[i * 4 + 1].floatValue
            let ymax = boxes[i * 4 + 2].floatValue
            let xmax = boxes[i * 4 + 3].floatValue

            let bbox = CGRect(
                x: CGFloat(xmin),
                y: CGFloat(ymin),
                width: CGFloat(xmax - xmin),
                height: CGFloat(ymax - ymin)
            )

            let classID = Int(truncating: classes[i])
            let label = "Class \(classID)"

            let detection = DetectionResult(
                className: label,
                boundingBox: bbox,
                score: score
            )
            results.append(detection)
        }

        return results
    }
    
    func predictFromVideo(url: URL, completion: @escaping ([DetectionResult]) -> Void) {
        var allDetections: [DetectionResult] = []
        
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("No video track found")
            completion([])
            return
        }
        
        do {
            let reader = try AVAssetReader(asset: asset)
            let outputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
            reader.add(trackOutput)
            
            reader.startReading()
            
            while let sampleBuffer = trackOutput.copyNextSampleBuffer(),
                  let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                
                let detections = predict(pixelBuffer: pixelBuffer)
                allDetections.append(contentsOf: detections)
            }
            
            completion(allDetections)
            
        } catch {
            print("Failed to read video: \(error)")
            completion([])
        }
    }
}
