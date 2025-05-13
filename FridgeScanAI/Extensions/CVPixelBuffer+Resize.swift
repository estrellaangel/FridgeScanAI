//
//  CVPixelBuffer+Resize.swift
//  FridgeScanAI
//
//  Created by Beckham Le on 4/25/25.
//

import CoreVideo
import CoreImage
import CoreML
import UIKit

extension CVPixelBuffer {
    func resize(to size: CGSize) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let context = CIContext()

        let scaleX = size.width / CGFloat(CVPixelBufferGetWidth(self))
        let scaleY = size.height / CGFloat(CVPixelBufferGetHeight(self))

        let resizedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        var resizedBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            CVPixelBufferGetPixelFormatType(self),
            attrs,
            &resizedBuffer
        )

        guard status == kCVReturnSuccess, let outputBuffer = resizedBuffer else {
            return nil
        }

        context.render(resizedImage, to: outputBuffer)
        return outputBuffer
    }

    func toMultiArray() -> MLMultiArray? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else { return nil }
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)

        guard let array = try? MLMultiArray(shape: [1, 640, 640, 3], dataType: .float32) else {
            return nil
        }

        for y in 0..<height {
            for x in 0..<width {
                let pixel = baseAddress.load(fromByteOffset: y * bytesPerRow + x * 4, as: UInt32.self)

                let blue = Float((pixel >> 0) & 0xFF) / 255.0
                let green = Float((pixel >> 8) & 0xFF) / 255.0
                let red = Float((pixel >> 16) & 0xFF) / 255.0

                array[[0, NSNumber(value: y), NSNumber(value: x), 0]] = NSNumber(value: red)
                array[[0, NSNumber(value: y), NSNumber(value: x), 1]] = NSNumber(value: green)
                array[[0, NSNumber(value: y), NSNumber(value: x), 2]] = NSNumber(value: blue)
            }
        }

        return array
    }
}
