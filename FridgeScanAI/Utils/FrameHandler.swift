//
//  FrameHandler.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/20/25.
//

import AVFoundation
import CoreVideo
import CoreML
import Vision
import CoreImage


func extractFirstFrame(from url: URL) -> CVPixelBuffer? {
    let asset = AVAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    
    do {
        let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
        let ciImage = CIImage(cgImage: cgImage)
        
        let context = CIContext()
        var pixelBuffer: CVPixelBuffer?
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary
        
        CVPixelBufferCreate(kCFAllocatorDefault, 640, 640, kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        
        if let pixelBuffer = pixelBuffer {
            context.render(ciImage, to: pixelBuffer)
            return pixelBuffer
        }
    } catch {
        print("Failed to extract frame: \(error)")
    }
    return nil
}

func pixelBufferToMLMultiArray(_ pixelBuffer: CVPixelBuffer) -> MLMultiArray? {
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
        return nil
    }

    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

    guard let array = try? MLMultiArray(shape: [1, 640, 640, 3], dataType: .float32) else {
        return nil
    }

    let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

    for y in 0..<min(640, height) {
        for x in 0..<min(640, width) {
            let pixelIndex = y * bytesPerRow + x * 4
            let r = Float(buffer[pixelIndex + 2]) / 255.0
            let g = Float(buffer[pixelIndex + 1]) / 255.0
            let b = Float(buffer[pixelIndex + 0]) / 255.0

            array[[0, y, x, 0] as [NSNumber]] = NSNumber(value: r)
            array[[0, y, x, 1] as [NSNumber]] = NSNumber(value: g)
            array[[0, y, x, 2] as [NSNumber]] = NSNumber(value: b)
        }
    }

    return array
}


