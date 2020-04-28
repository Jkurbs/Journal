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
    
    var recordButtonView = RecordButtonView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .midnight
        addSubview(recordButtonView)
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()

    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            recordButtonView.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButtonView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -120.0),
            recordButtonView.widthAnchor.constraint(equalToConstant: 80.0),
            recordButtonView.heightAnchor.constraint(equalToConstant: 80.0),
        ])
        recordButtonView.layer.cornerRadius = recordButtonView.bounds.size.width/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
