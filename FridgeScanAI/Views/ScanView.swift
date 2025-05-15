//
//  ScanView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel & Beckham Le on 4/7/25.
//

import SwiftUI
import AVFoundation

//Bridges SwiftUI and UIKit
struct ScanView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    @Binding var videoURL: URL?
    @Binding var didFinishRecording: Bool

    // Creates a Coordinator class instance
    func makeCoordinator() -> Coordinator {
        Coordinator(isRecording: $isRecording, videoURL: $videoURL, didFinishRecording: $didFinishRecording)
    }

    // Instantiates camera controller
    func makeUIViewController(context: Context) -> ScanViewController {
        let controller = ScanViewController()
        controller.coordinator = context.coordinator
        return controller
    }

    // Starts or stops the recording based on that state
    func updateUIViewController(_ uiViewController: ScanViewController, context: Context) {
        uiViewController.updateRecordingState(isRecording)
    }

    // Allows ScanViewController to modify SwiftUI state
    class Coordinator {
        var isRecording: Binding<Bool>
        var videoURL: Binding<URL?>
        var didFinishRecording: Binding<Bool>
        
        init(isRecording: Binding<Bool>, videoURL: Binding<URL?>, didFinishRecording: Binding<Bool>) {
            self.isRecording = isRecording
            self.videoURL = videoURL
            self.didFinishRecording = didFinishRecording
        }
        
    }
}

// Manages the camera preview and video recording
class ScanViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var movieOutput = AVCaptureMovieFileOutput()
    var coordinator: ScanView.Coordinator?
    
    var shouldRestartRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    // Sets up camera to get input, make output, and preview camera
    private func setupCamera() {
        captureSession = AVCaptureSession() // initializes camera session

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to access camera")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("Failed to create video input: \(error)")
            return
        }

        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        // Adds the preview to the view and starts the session.
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }

    // Ensures the camera preview fills the screen on rotation or resize
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    // Starts recording to a temporary .mov file
    func startRecording() {
        guard captureSession.isRunning else {
            print("Capture session not running yet. Cannot start recording.")
            return
        }
        if !movieOutput.isRecording {

            //if camera is not already recording, then add new video
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            coordinator?.isRecording.wrappedValue = true
            
        }else{
            // If already recording, flags to restart after stopping
            shouldRestartRecording = true
            stopRecording()
        }
    }

    //stops camera recording
    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            coordinator?.isRecording.wrappedValue = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      // If the session isn’t running (e.g. you switched tabs), restart it:
      if !captureSession.isRunning {
        DispatchQueue.global(qos: .userInitiated).async {
          self.captureSession.startRunning()
        }
      }
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      // Pause when we leave
      if captureSession.isRunning {
        captureSession.stopRunning()
      }
    }
     
    // Called by SwiftUI whenever isRecording changes
    func updateRecordingState(_ recording: Bool) {
        recording ? startRecording() : stopRecording()
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error)")
            return
        }

        print("Recording finished: \(outputFileURL)")
        DispatchQueue.main.async {
            // Retrieves the URL to the app's Documents directory on the device
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // Appends the filename to the documentsDir path
            let safeURL = documentsDir.appendingPathComponent("LatestScan.mov")

            do {
                // Checks if LatestScan.mov already exists, and deletes it if it does
                if FileManager.default.fileExists(atPath: safeURL.path) {
                    try FileManager.default.removeItem(at: safeURL)
                }
                // Copies the video file from the temp directory to a more permanent location
                try FileManager.default.copyItem(at: outputFileURL, to: safeURL)
                print("Moved video to safe path: \(safeURL.path)")

                // Updates @Binding var videoURL in SwiftUI so the parent view knows where the saved file is
                self.coordinator?.videoURL.wrappedValue = safeURL
                // Signals to SwiftUI that recording has completed
                self.coordinator?.didFinishRecording.wrappedValue = true
            } catch {
                print("Failed to move file to documents directory: \(error)")
            }
        }
    }
}
