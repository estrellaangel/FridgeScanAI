//
//  scanUploadService.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/19/25.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreML
import Vision
import VideoToolbox

enum UploadError: Error {
    case fileMissing
    case uploadFailed
    case metadataFailed
}

struct ScanUploadService {
    static func upload(videoURL: URL, completion: @escaping (Result<DocumentSnapshot, Error>) -> Void) {
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            completion(.failure(UploadError.fileMissing))
            return
        }

        // ✅ Run Core ML
        let detectedIngredients: [String]
        if let pixelBuffer = extractFirstFrame(from: videoURL) {
            detectedIngredients = runModel(on: pixelBuffer)
        } else {
            detectedIngredients = []
        }

        let storage = Storage.storage()
        let userID = Auth.auth().currentUser?.uid ?? "anonymous"
        let filename = "scan_\(UUID().uuidString).mov"
        let storageRef = storage.reference().child("userVideos/\(userID)/\(filename)")

        storageRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error ?? UploadError.metadataFailed))
                    return
                }

                let db = Firestore.firestore()
                let docRef = db.collection("scans").document()

                let scanData: [String: Any] = [
                    "userID": userID,
                    "timestamp": Timestamp(date: Date()),
                    "videoURL": downloadURL.absoluteString,
                    "detectedIngredients": detectedIngredients,
                    "notes": ""
                ]

                docRef.setData(scanData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        docRef.getDocument { snapshot, error in
                            if let snapshot = snapshot, snapshot.exists {
                                completion(.success(snapshot))
                            } else {
                                completion(.failure(error ?? UploadError.metadataFailed))
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func runModel(on pixelBuffer: CVPixelBuffer) -> [String] {
//        do {
//            let model = try fridge_scan_ai_fixed(configuration: MLModelConfiguration())
//
//            guard let inputArray = pixelBufferToMLMultiArray(pixelBuffer) else {
//                print("❌ Failed to convert pixel buffer to input array")
//                return []
//            }
//            
//            print("✅ Converted pixel buffer to input array")
//
//                let output = try model.prediction(serving_default_input: inputArray)
//
//                // Check output feature names
//                let countShapedArray = output.TFLite_Detection_PostProcess3ShapedArray
//                let detectionCount = countShapedArray[0]
//                print("✅ Detection count: \(detectionCount)")
//
//
//            return []
//
//        } catch {
//            print("❌ Model prediction failed: \(error)")
//            return []
//        }
        
        return ["apple", "orange"]
        
    }
    
}
