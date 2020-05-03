
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
import Accelerate
import FirebaseAuth

class CameraController: NSObject {
    
    lazy var captureSession = AVCaptureSession()
    lazy var fileOutput = AVCaptureMovieFileOutput()
    let cameraOutput = AVCapturePhotoOutput()
    var audioDataOutput: AVCaptureAudioDataOutput!
    
    var session: AVCaptureSession?
    var fileName: String?
    var speech: String?
    var image: UIImage?
    var sentimentScore: Double?
    var sentiment: String?
    
    var audioInput: AVCaptureDeviceInput?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func setUpCaptureSession() {
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Add inputs
        let camera = bestCamera()
        
        // Video
        guard let captureInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(captureInput) else {
                return
                //                fatalError("Can't create the input form the camera")
        }
        captureSession.addInput(captureInput)
        
        
        if captureSession.canSetSessionPreset(.high) { // FUTURE: Play with 4k
            captureSession.sessionPreset = .high
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
        
        audioDataOutput = AVCaptureAudioDataOutput()
        
        guard captureSession.canAddOutput(audioDataOutput) else {
            return
        }
        
        audioDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(audioDataOutput)
        print("videodataoutput added")
        
        
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
        
        let recordingFormat: AVAudioFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {[weak self] (buffer:AVAudioPCMBuffer, when:AVAudioTime) in
            guard let self = self else {
                return
            }
            self.recognitionRequest?.append(buffer)
        }
        
        
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
                self.speech = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
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
    
    func switchCamera() {
        
        // Get current input
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        
        
        // Begin new session configuration and defer commit
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }
        
        // Create new capture input
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        captureSession.addInput(deviceInput)
    }
    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    fileprivate func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    // Start recording
    func startRecording() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = NSUUID().uuidString
        self.fileName = name
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        fileOutput.startRecording(to: fileURL, recordingDelegate: self)
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            do {
                try startSpeechRecording()
            } catch {
                print("Error with speech: \(error)")
            }
        }
    }
    
    func stopRecording() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            recognitionRequest?.endAudio()
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
    
    func createThumbnail(videoURL: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: videoURL)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return UIImage(named: "ico_placeholder")
        }
    }
}


// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        let entry = Entry(name: self.fileName ?? "", speech: self.speech ?? "", sentiment: self.sentiment ?? "Unknown", sentimentScore: self.sentimentScore ?? 0.0, date: CachedDateFormattingHelper.shared.formatTodayDate(), imageUrl: outputFileURL.absoluteString)

        let image = createThumbnail(videoURL: outputFileURL.absoluteString)
        guard let data = image?.jpegData(compressionQuality: 1.0) else { return }
        let userId =  Auth.auth().currentUser!.uid
        DataService.shared.saveImg(id: self.fileName!, userID: userId, data: data) { result in
            if let result = try? result.get() as? String {
                let sentiment = AI.shared.sentimentAnalysis(string: self.speech ?? "")
                DataService.shared.saveEtries(name: self.fileName ?? "", speech: self.speech ?? "", sentimen: sentiment.sentiment ?? "Unknown", sentimentScore: sentiment.score ?? 0.0, date: CachedDateFormattingHelper.shared.formatTodayDate(), completion: { result in
                    NotificationCenter.default.post(name: NSNotification.Name("testentry"), object: nil, userInfo: ["entry": entry])
                    if let _ = try? result.get() {
                        DispatchQueue.main.async {
                            //TODO: - show alert to user
                        }
                    }
                })
                DataService.shared.RefEntries.child(userId).child(self.fileName!).updateChildValues(["imageUrl": result])
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {

    }
}

extension CameraController: AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == audioDataOutput {
            
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
    }
}
