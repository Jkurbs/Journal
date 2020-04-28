//
//  RecordButtonView.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit

class RecordButtonView: UIView {
    
    let recordButton = UIButton()
    let blurredEffectView = UIVisualEffectView()
    let rotationButton = UIButton()
    
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
    
    private func setupViews() {
        
        translatesAutoresizingMaskIntoConstraints = false
        let blurEffect = UIBlurEffect(style: .regular)
        blurredEffectView.effect = blurEffect
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurredEffectView)
        
        recordButton.backgroundColor = .cloud
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        addSubview(recordButton)
        
        let circleImage = UIImage(systemName: "arrow.2.circlepath")!
        let whiteCircleimage = circleImage.withTintColor(.cloud, renderingMode: .alwaysOriginal)
        
        rotationButton.translatesAutoresizingMaskIntoConstraints = false
        rotationButton.setImage(whiteCircleimage, for: .normal)
        
        addSubview(rotationButton)
    }
    
    @objc private func startRecording() {
        NotificationCenter.default.post(name: .startRecordingNotification, object: nil)
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
