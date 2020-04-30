
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
                
                let sentiment = AI.shared.sentimentAnalysis(string: result.bestTranscription.formattedString)
                print("SENTIMENT: \(sentiment.sentiment)")
                print("SENTIMENT: \(sentiment.score)")

                
                
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
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
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
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
    
    func createThumbnail(videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
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
}


// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let image = createThumbnail(videoURL: outputFileURL)
        guard let data = image?.jpegData(compressionQuality: 1.0) else { return }
        let userId =  Auth.auth().currentUser!.uid
        DataService.shared.saveImg(id: self.fileName!, userID: userId, data: data) { result in
            if let result = try? result.get() {
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
            print("AUDIO OUTPUT")
        }
        //        DispatchQueue.main.async {
        //            print("DELEGATE")
        //
        //            let channel = connection.audioChannels[1];
        //            let averagePowerLevel = channel.averagePowerLevel
        //            print("AVERAGE POWER: \(averagePowerLevel)")
        //        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
    }
}




////
////  CameraController.swift
////  Journal
////
////  Created by Kerby Jean on 4/28/20.
////  Copyright © 2020 Kerby Jean. All rights reserved.
////
//
//import Foundation
//import AVFoundation
//import UIKit
//import Speech
//import Accelerate
//
//class CameraController: NSObject {
//
//    // MARK: - Properties
//
//    lazy var captureSession = AVCaptureSession()
//    lazy var fileOutput = AVCaptureMovieFileOutput()
//    let cameraOutput = AVCapturePhotoOutput()
//    var audioOutput: AVCaptureAudioDataOutput!
//    var videoOutput: AVCaptureVideoDataOutput?
//
//    private var videoConnection:AVCaptureConnection?
//    private var audioConnection:AVCaptureConnection?
//
//
//    var session: AVCaptureSession?
//    var filename = ""
//    var speech: String?
//
//    private var _adpater: AVAssetWriterInputPixelBufferAdaptor?
//    private var _time: Double = 0
//
//    var audioInput: AVCaptureDeviceInput?
//
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//
//    private var _assetWriter: AVAssetWriter?
//    private var _assetWriterInput: AVAssetWriterInput?
//
//
//    func setUpCaptureSession() {
//
//        captureSession.beginConfiguration()
//        captureSession.sessionPreset = AVCaptureSession.Preset.high
//
//        // Add inputs
//        let camera = bestCamera()
//
//        // Video
//        // Add inputs
//        guard let captureInput = try? AVCaptureDeviceInput(device: camera),
//            captureSession.canAddInput(captureInput) else {
//                return
//        }
//        captureSession.addInput(captureInput)
//
//
//        if captureSession.canSetSessionPreset(.high) { // FUTURE: Play with 4k
//            captureSession.sessionPreset = .high
//        }
//
//        if captureSession.canAddOutput(cameraOutput){
//            captureSession.addOutput(cameraOutput)
//        }
//
//        let microphone = bestAudio()
//
//        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
//            captureSession.canAddInput(audioInput) else {
//                return
//        }
//
//        captureSession.addInput(audioInput)
//        self.audioInput = audioInput
//
//
//        // Add outputs
//
//
//        // setup video output
//        do {
//            let videoDataOutput = AVCaptureVideoDataOutput()
//            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
//            videoDataOutput.alwaysDiscardsLateVideoFrames = true
//            let queue = DispatchQueue(label: "com.shu223.videosamplequeue")
//            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
//            guard captureSession.canAddOutput(videoDataOutput) else {
//                fatalError()
//            }
//            captureSession.addOutput(videoDataOutput)
//            videoConnection = videoDataOutput.connection(with: .video)
//        }
//
//        // setup audio output
//        do {
//            let audioDataOutput = AVCaptureAudioDataOutput()
//            let queue = DispatchQueue(label: "com.shu223.audiosamplequeue")
//            audioDataOutput.setSampleBufferDelegate(self, queue: queue)
//            guard captureSession.canAddOutput(audioDataOutput) else {
//                fatalError()
//            }
//            captureSession.addOutput(audioDataOutput)
//            audioConnection = audioDataOutput.connection(with: .audio)
//        }
//
//        captureSession.commitConfiguration()
//    }
//
//
//
//    private func startSpeechRecording() throws {
//
//        // Cancel the previous task if it's running.
//        recognitionTask?.cancel()
//        self.recognitionTask = nil
//
//        // Configure the audio session for the app.
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        let inputNode = audioEngine.inputNode
//
//        let recordingFormat: AVAudioFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {[weak self] (buffer:AVAudioPCMBuffer, when:AVAudioTime) in
//            guard let self = self else {
//                return
//            }
//            self.recognitionRequest?.append(buffer)
//        }
//
//
//        // Create and configure the speech recognition request.
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//
//        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
//        recognitionRequest.shouldReportPartialResults = true
//
//        // Keep speech recognition data on device
//        if #available(iOS 13, *) {
//            recognitionRequest.requiresOnDeviceRecognition = false
//        }
//
//        // Create a recognition task for the speech recognition session.
//        // Keep a reference to the task so that it can be canceled.
//        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
//            var isFinal = false
//
//            if let result = result {
//                // Update the text view with the results.
//                print("SPEECH: \(result.bestTranscription.formattedString)")
//                self.speech = result.bestTranscription.formattedString
//                isFinal = result.isFinal
//            }
//
//            if error != nil || isFinal {
//                // Stop recognizing speech if there is a problem.
//                self.audioEngine.stop()
//                inputNode.removeTap(onBus: 0)
//
//                self.recognitionRequest = nil
//                self.recognitionTask = nil
//            }
//        }
//        audioEngine.prepare()
//        try audioEngine.start()
//    }
//
//    func startCaptureSession() {
//        captureSession.startRunning()
//    }
//
//    func stopCaptureSession() {
//        captureSession.stopRunning()
//    }
//
//    func bestCamera() -> AVCaptureDevice {
//        // All iPhones have a wide angle camera (front + back)
//        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
//            return ultraWideCamera
//        }
//
//        if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//            return wideCamera
//        }
//        // Future: Add a button to toggle front/back camera
//        fatalError("No cameras on the device (or you're running this on a Simulator which isn't supported)")
//    }
//
//
//    private func bestAudio() -> AVCaptureDevice {
//        if let device = AVCaptureDevice.default(for: .audio) {
//            return device
//        }
//
//        fatalError("No audio")
//    }
//
//
//
//    func switchCamera() {
//
//        // Get current input
//        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
//
//
//        // Begin new session configuration and defer commit
//        captureSession.beginConfiguration()
//        defer { captureSession.commitConfiguration() }
//
//        // Create new capture device
//        var newDevice: AVCaptureDevice?
//        if input.device.position == .back {
//            newDevice = captureDevice(with: .front)
//        } else {
//            newDevice = captureDevice(with: .back)
//        }
//
//        // Create new capture input
//        var deviceInput: AVCaptureDeviceInput!
//        do {
//            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
//        } catch let error {
//            print(error.localizedDescription)
//            return
//        }
//
//        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
//            for input in inputs {
//                captureSession.removeInput(input)
//            }
//        }
//        captureSession.addInput(deviceInput)
//    }
//
//    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
//    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
//        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
//        for device in discoverySession.devices {
//            if device.position == position {
//                return device
//            }
//        }
//
//        return nil
//    }
//
//    fileprivate func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
//        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
//
//        for device in devices {
//            if device.position == position {
//                return device
//            }
//        }
//        return nil
//    }
//
//    private enum _CaptureState {
//        case idle, start, capturing, end
//    }
//
//    private var _captureState = _CaptureState.idle
//
//
//    // Start recording
//    func startRecording() {
//
//        switch _captureState {
//        case .idle:
//            _captureState = .start
//        case .capturing:
//            _captureState = .end
//        default:
//            break
//        }
//        //        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        //        let formatter = ISO8601DateFormatter()
//        //        formatter.formatOptions = [.withInternetDateTime]
//        //
//        //        let name = formatter.string(from: Date())
//        //        self.filename = name
//        //        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
//        //        fileOutput.startRecording(to: fileURL, recordingDelegate: self)
//        //
//        //        if audioEngine.isRunning {
//        //            audioEngine.stop()
//        //            recognitionRequest?.endAudio()
//        //        } else {
//        //            do {
//        //                try startSpeechRecording()
//        //            } catch {
//        //                print("Error with speech: \(error)")
//        //            }
//        //        }
//    }
//
//    func createThumbnailOfVideoFromFileURL(videoURL: String) -> UIImage? {
//        let asset = AVAsset(url: URL(string: videoURL)!)
//        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
//        assetImgGenerate.appliesPreferredTrackTransform = true
//        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
//        do {
//            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
//            let thumbnail = UIImage(cgImage: img)
//            return thumbnail
//        } catch {
//            return UIImage(named: "ico_placeholder")
//        }
//    }
//
//    func stopRecording() {
//        if fileOutput.isRecording {
//            fileOutput.stopRecording()
//            recognitionRequest?.endAudio()
//        }
//    }
//
//
//    func captureImage() {
//
//    }
//
//    var outputSize = CGSize(width:720, height:1280)
//
//}
//
//// MARK: - SFSpeechRecognizerDelegate
//
//extension CameraController: SFSpeechRecognizerDelegate {
//
//    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        if available {
//            print("AVAILABLE")
//        } else {
//            print("NOT AVAILABLE")
//        }
//    }
//}
//
//
//// MARK: - AVCaptureFileOutputRecordingDelegate
//
//extension CameraController: AVCaptureFileOutputRecordingDelegate {
//
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//    }
//
//
//    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
//
//    }
//
//    func mappingRange(_ x: Double, _ in_min: Double, _ in_max: Double, _ out_min: Double, _ out_max: Double) -> Double {
//        let slope = 1.0 * (out_max - out_min) / (in_max - in_min)
//        return out_min + slope * (x - in_min)
//    }
//
//}
//
//
//
//extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
//
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//
//        if connection == self.audioConnection {
//            print("ITS AUDIO")
//            for channel in connection.audioChannels {
//                let power = Float(mappingRange(Double(channel.averagePowerLevel), -60, 0, 0, 1))
//                NotificationCenter.default.post(name: NSNotification.Name("test2"), object: nil, userInfo: ["decibel": power])
//                print("AVERAGE POWER: \(power)")
//            }
//        } else {
//
//            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
//
//            switch _captureState {
//            case .start:
//                // Set up recorder
//                filename = UUID().uuidString
//                let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mov")
//
//                guard let writer = try? AVAssetWriter(outputURL: videoPath, fileType: .mov) else {
//                    fatalError("AVAssetWriter error")
//                }
//
//                let outputSettings = [AVVideoCodecKey : AVVideoCodecType.h264, AVVideoWidthKey : NSNumber(value: Float(outputSize.width)), AVVideoHeightKey : NSNumber(value: Float(outputSize.height))] as [String : Any]
//
//                guard writer.canApply(outputSettings: outputSettings, forMediaType: AVMediaType.video) else {
//                    fatalError("Negative : Can't apply the Output settings...")
//                }
//
//
//            let input = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
//                   let sourcePixelBufferAttributesDictionary = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32ARGB), kCVPixelBufferWidthKey as String: NSNumber(value: Float(outputSize.width)), kCVPixelBufferHeightKey as String: NSNumber(value: Float(outputSize.height))]
//                   let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
//
//                if writer.canAdd(input) {
//                    writer.add(input)
//                }
//                if writer.startWriting() {
//                    writer.startSession(atSourceTime: CMTime.zero)
//                    assert(pixelBufferAdaptor.pixelBufferPool != nil)
//                }
//            case .capturing:
//                if _assetWriterInput?.isReadyForMoreMediaData == true {
//                    let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
//                    _adpater?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
//                }
//                break
//            case .end:
//                guard _assetWriterInput?.isReadyForMoreMediaData == true, _assetWriter!.status != .failed else { break }
//                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mov")
//                _assetWriterInput?.markAsFinished()
//                _assetWriter?.finishWriting { [weak self] in
//                    self?._captureState = .idle
//                    self?._assetWriter = nil
//                    self?._assetWriterInput = nil
//                    DispatchQueue.main.async {
//                        print("DONE: \(url)")
////                        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
////                        self?.present(activity, animated: true, completion: nil)
//                    }
//                }
//            default:
//                break
//            }
//        }
//
//
//
//
//
//
//
//
//        //            let fileManager = FileManager.default
//        //            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        //            guard let documentDirectory: URL = urls.first else {
//        //                fatalError("documentDir Error")
//        //            }
//        //
//        //            filename = UUID().uuidString
//        //            let videoOutputURL = documentDirectory.appendingPathComponent("\(filename).mp4")
//        //
//        //            if FileManager.default.fileExists(atPath: videoOutputURL.path) {
//        //                do {
//        //                    try FileManager.default.removeItem(atPath: videoOutputURL.path)
//        //                } catch {
//        //                    NSLog("Unable to delete file: \(error)")
//        //                }
//        //            }
//        //
//        //            guard let videoWriter = try? AVAssetWriter(outputURL: videoOutputURL, fileType: AVFileType.mp4) else {
//        //                fatalError("AVAssetWriter error")
//        //            }
//        //
//        //            let outputSettings = [AVVideoCodecKey : AVVideoCodecType.h264, AVVideoWidthKey : NSNumber(value: Float(outputSize.width)), AVVideoHeightKey : NSNumber(value: Float(outputSize.height))] as [String : Any]
//        //
//        //            guard videoWriter.canApply(outputSettings: outputSettings, forMediaType: AVMediaType.video) else {
//        //                fatalError("Negative : Can't apply the Output settings...")
//        //            }
//        //
//        //            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
//        //            let sourcePixelBufferAttributesDictionary = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32ARGB), kCVPixelBufferWidthKey as String: NSNumber(value: Float(outputSize.width)), kCVPixelBufferHeightKey as String: NSNumber(value: Float(outputSize.height))]
//        //            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
//        //
//        //            if videoWriter.canAdd(videoWriterInput) {
//        //                videoWriter.add(videoWriterInput)
//        //            }
//        //
//        //            if videoWriter.startWriting() {
//        //                videoWriter.startSession(atSourceTime: CMTime.zero)
//        //                assert(pixelBufferAdaptor.pixelBufferPool != nil)
//        //
//        //                let media_queue = DispatchQueue(__label: "mediaInputQueue", attr: nil)
//        //
//        //                videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: { () -> Void in
//        //                    let fps: Int32 = 1
//        //                    let frameDuration = CMTimeMake(value: 1, timescale: fps)
//        //
//        //                    var frameCount: Int64 = 0
//        //                    var appendSucceeded = true
//        //                    videoWriterInput.markAsFinished()
//        //                    videoWriter.finishWriting { () -> Void in
//        //                        print("FINISHED!!!!!")
//        //                    }
//        //                })
//        //            }
//    }
//}
//
//// MARK: - AVCapturePhotoCaptureDelegate
//
//extension CameraController: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//
//    }
//}
//
