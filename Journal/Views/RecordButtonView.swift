//
//  RecordButtonView.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit

class RecordButtonView: UIView {
    
    // MARK: - Properties
    
    let recordButton = UIButton()
    let blurredEffectView = UIVisualEffectView()
    let rotationButton = UIButton()
    var recordIsSelected = false
    
    var recordButtonImage: UIImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    // MARK: - Functions
    
    private func setupViews() {
        
        translatesAutoresizingMaskIntoConstraints = false
        let blurEffect = UIBlurEffect(style: .regular)
        blurredEffectView.effect = blurEffect
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurredEffectView)
        
        recordButton.backgroundColor = .cloud
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(startRecording(_:)), for: .touchUpInside)
        addSubview(recordButton)
        
        let recordImageConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let recordButtonImage = UIImage(systemName: "app.fill", withConfiguration: recordImageConfiguration)!
        self.recordButtonImage = recordButtonImage.withTintColor(UIColor.systemRed, renderingMode: .alwaysOriginal)

        let configuration = UIImage.SymbolConfiguration(scale: .large)
        let circleImage = UIImage(systemName: "arrow.2.circlepath", withConfiguration: configuration)!
        let whiteCircleimage = circleImage.withTintColor(.cloud, renderingMode: .alwaysOriginal)
        
        rotationButton.translatesAutoresizingMaskIntoConstraints = false
        rotationButton.setImage(whiteCircleimage, for: .normal)
        addSubview(rotationButton)
    }
    
    @objc private func startRecording(_ sender: UIButton) {
        if recordIsSelected == true {
            recordIsSelected = false
            sender.setImage(nil, for: .normal)
            NotificationCenter.default.post(name: .stopRecordingNotification, object: nil)
        } else {
            recordIsSelected = true
            sender.setImage(recordButtonImage, for: .normal)
            NotificationCenter.default.post(name: .startRecordingNotification, object: nil)
        }
    }
    
    @objc private func rotateCamera() {
        NotificationCenter.default.post(name: .rotateCameraNotification, object: nil)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurredEffectView.heightAnchor.constraint(equalTo: heightAnchor, constant: -20),
            blurredEffectView.widthAnchor.constraint(equalTo: blurredEffectView.heightAnchor),
            blurredEffectView.centerXAnchor.constraint(equalTo: centerXAnchor),
            blurredEffectView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            recordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            recordButton.heightAnchor.constraint(equalTo: blurredEffectView.heightAnchor, constant: -30),
            recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor),
            
            rotationButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            rotationButton.leftAnchor.constraint(equalTo: rightAnchor, constant: -16.0),
            rotationButton.widthAnchor.constraint(equalToConstant: 30),
            rotationButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        recordButton.layer.cornerRadius = recordButton.bounds.size.width/2
        blurredEffectView.layer.cornerRadius = blurredEffectView.bounds.size.width/2
        blurredEffectView.clipsToBounds = true
    }
}
