//
//  ScanView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI
import AVFoundation

struct ScanView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    @Binding var videoURL: URL?
    @Binding var didFinishRecording: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isRecording: $isRecording, videoURL: $videoURL, didFinishRecording: $didFinishRecording)
    }

    func makeUIViewController(context: Context) -> ScanViewController {
        let controller = ScanViewController()
        controller.coordinator = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: ScanViewController, context: Context) {
        uiViewController.updateRecordingState(isRecording)
        uiViewController.restartSessionIfNeeded() 
    }

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

    private func setupCamera() {
        captureSession = AVCaptureSession()

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

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func startRecording() {
        if !movieOutput.isRecording {

            //then add new video
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            coordinator?.isRecording.wrappedValue = true
            
        }else{
            shouldRestartRecording = true
            stopRecording()
        }
    }

    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            coordinator?.isRecording.wrappedValue = false
        }
    }
    
    func restartSessionIfNeeded() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

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
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let safeURL = documentsDir.appendingPathComponent("LatestScan.mov")

            do {
                if FileManager.default.fileExists(atPath: safeURL.path) {
                    try FileManager.default.removeItem(at: safeURL)
                }
                try FileManager.default.copyItem(at: outputFileURL, to: safeURL)
                print("Moved video to safe path: \(safeURL.path)")

                self.coordinator?.videoURL.wrappedValue = safeURL
                self.coordinator?.didFinishRecording.wrappedValue = true
            } catch {
                print("Failed to move file to documents directory: \(error)")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
}
