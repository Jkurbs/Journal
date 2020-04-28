//
//  CameraController.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Speech

class CameraController: NSObject {
    
    lazy var captureSession = AVCaptureSession()
    lazy var fileOutput = AVCaptureMovieFileOutput()
    let cameraOutput = AVCapturePhotoOutput()
    
    var session: AVCaptureSession?
    var videoPath: String?
    
    var audioInput: AVCaptureDeviceInput?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func setUpCaptureSession() {
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        // Add inputs
        let camera = bestCamera()
        
        // Video
        guard let captureInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(captureInput) else {
                return
//                fatalError("Can't create the input form the camera")
        }
        captureSession.addInput(captureInput)
        
        
        if captureSession.canSetSessionPreset(.hd4K3840x2160) { // FUTURE: Play with 4k
            captureSession.sessionPreset = .hd4K3840x2160
        }
        
        if captureSession.canAddOutput(cameraOutput){
            captureSession.addOutput(cameraOutput)
        }
        
        // Add outputs
        let microphone = bestAudio()
        
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
//                fatalError("Can't create microphone input")
            return
        }
        captureSession.addInput(audioInput)
        self.audioInput = audioInput
        
        // Recording to disk
        guard captureSession.canAddOutput(fileOutput) else {
//            fatalError("Cannot record to disk")
            return 
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
    }
    
    
    
    private func startSpeechRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
                
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                print("SPEECH: \(result.bestTranscription.formattedString)")
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    
    func startCaptureSession() {
        captureSession.startRunning()
    }
    
    func stopCaptureSession() {
        captureSession.stopRunning()
    }
    
    func bestCamera() -> AVCaptureDevice {
        // All iPhones have a wide angle camera (front + back)
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        
        if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideCamera
        }
        
        // Future: Add a button to toggle front/back camera
        
        fatalError("No cameras on the device (or you're running this on a Simulator which isn't supported)")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    func startRecording() {
        
    }
    
    
    func stopRecording() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        }
    }
    
    
    func captureImage() {
        
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension CameraController: SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("AVAILABLE")
        } else {
            print("NOT AVAILABLE")
        }
    }
}


// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
    }
}

