//
//  VideoObjectDetector.swift
//  FridgeScanAI
//
//  Created by Beckham Le on 5/8/25.
//

/*
 
 Class to encapsulate logic for object detection and classification using CoreML model
 
 */

import Foundation
import AVFoundation
import Vision
import CoreML

class VideoObjectDetector {
    private let request: VNCoreMLRequest

    init?() {
        // Load your Core ML model
        guard let coreMLModel = try? FridgeScanAI(configuration: .init()).model,
              let visionModel = try? VNCoreMLModel(for: coreMLModel) else {
            return nil
        }

        // Make a Vision request
        request = VNCoreMLRequest(model: visionModel)
        request.imageCropAndScaleOption = .scaleFill
    }

    // Video Processing Method
    func process(videoURL: URL,
                 frameHandler: @escaping (CMTime, [VNRecognizedObjectObservation]) -> Void, // a callback to return timestamped detection results per frame
                 completion: @escaping () -> Void) {
        let asset = AVAsset(url: videoURL)  // load video as AVAsset
        guard let reader = try? AVAssetReader(asset: asset),    // Initializes an AVAssetReader to read video frames
              let track = asset.tracks(withMediaType: .video).first else {
            completion()
            return
        }

        // Set pixel format and begin reading
        let settings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(output)
        reader.startReading()

        // Runs loop on background thread, reads one frame at a time and extracts image buffer
        DispatchQueue.global(qos: .userInitiated).async {
            while reader.status == .reading {
                guard let sample = output.copyNextSampleBuffer(),
                      let buffer = CMSampleBufferGetImageBuffer(sample) else {
                    break
                }

                let timestamp = CMSampleBufferGetPresentationTimeStamp(sample)  // get timestamp of frame
                let handler = VNImageRequestHandler(cvPixelBuffer: buffer,  //Uses VNImageRequestHandler to pass the pixel buffer into Vision
                                                    orientation: .up,
                                                    options: [:])
                try? handler.perform([self.request])    // performs the Vision request using your Core ML model
                if let obs = self.request.results as? [VNRecognizedObjectObservation] { // if vision request produces results casts them to bounding boxes & labels
                    DispatchQueue.main.async {
                        frameHandler(timestamp, obs)
                    }
                }
            }
            DispatchQueue.main.async {
                completion()    // after reading is done, call completion
            }
        }
    }
}
