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

    func makeCoordinator() -> Coordinator {
        Coordinator(isRecording: $isRecording, videoURL: $videoURL)
    }

    func makeUIViewController(context: Context) -> ScanViewController {
        let controller = ScanViewController()
        controller.coordinator = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: ScanViewController, context: Context) {
        uiViewController.updateRecordingState(isRecording)
    }

    class Coordinator {
        var isRecording: Binding<Bool>
        var videoURL: Binding<URL?>

        init(isRecording: Binding<Bool>, videoURL: Binding<URL?>) {
            self.isRecording = isRecording
            self.videoURL = videoURL
        }
    }
}

class ScanViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var movieOutput = AVCaptureMovieFileOutput()
    var coordinator: ScanView.Coordinator?

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
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            coordinator?.isRecording.wrappedValue = true
        }
    }

    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            coordinator?.isRecording.wrappedValue = false
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
            self.coordinator?.videoURL.wrappedValue = outputFileURL
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
}
