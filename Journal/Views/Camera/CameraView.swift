//
//  CameraView.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView {
    
    // MARK: - Properties
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPlayerView: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return videoPlayerView.session }
        set { videoPlayerView.session = newValue }
    }
    
    var recordingView = RecordingView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    // MARK: - Functions
    
    private func setupView() {
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .midnight
        addSubview(recordingView)
        
        recordingView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(recordingStarted), name: .startRecordingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recordingStoped), name: .stopRecordingNotification, object: nil)
    }    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()

    }
    
    @objc func recordingStarted() {
        recordingView.isHidden = false
    }
    
    @objc func recordingStoped() {
        recordingView.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            recordingView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.0),
            recordingView.leftAnchor.constraint(equalTo: leftAnchor, constant: 24.0),
            recordingView.widthAnchor.constraint(equalToConstant: 100),
            recordingView.heightAnchor.constraint(equalToConstant: 50.0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
