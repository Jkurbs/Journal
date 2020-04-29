//
//  MediaAccessView.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import AVFoundation

class MediaAccessView: UIView {
    
    var cameraAccessButton = UIButton()
    var cameraAccessImageView = UIImageView()
    var audioAccessButton = UIButton()
    var audioAccessImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        backgroundColor = .midnight
        
        let font = UIFont.systemFont(ofSize: 17)
        let color = UIColor.systemBlue
        
        cameraAccessButton.translatesAutoresizingMaskIntoConstraints = false
        cameraAccessButton.setTitle("Allow access to Camera", for: .normal)
        cameraAccessButton.titleLabel?.font = font
        cameraAccessButton.setTitleColor(color, for: .normal)
        cameraAccessButton.addTarget(self, action: #selector(requestCameraAccess), for: .touchUpInside)
        
        cameraAccessImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraAccessImageView.image = UIImage(systemName: "checkmark")
        cameraAccessImageView.contentMode = .scaleAspectFit
        cameraAccessImageView.isHidden = true
        
        audioAccessButton.translatesAutoresizingMaskIntoConstraints = false
        audioAccessButton.setTitle("Allow access to microphone", for: .normal)
        audioAccessButton.titleLabel?.font = font
        audioAccessButton.setTitleColor(color, for: .normal)
        audioAccessButton.addTarget(self, action: #selector(requestAudioAccess), for: .touchUpInside)

        
        audioAccessImageView.translatesAutoresizingMaskIntoConstraints = false
        audioAccessImageView.image = UIImage(systemName: "checkmark")
        audioAccessImageView.contentMode = .scaleAspectFit
        audioAccessImageView.isHidden = true

        addSubview(cameraAccessButton)
        addSubview(audioAccessButton)
        addSubview(cameraAccessImageView)
        addSubview(audioAccessImageView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    @objc func requestCameraAccess() {
        NotificationCenter.default.post(name: .requestCameraNotification, object: nil)
    }
    
    @objc func requestAudioAccess() {
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
         
            cameraAccessButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraAccessButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            cameraAccessImageView.leftAnchor.constraint(equalTo: cameraAccessButton.rightAnchor, constant: 16.0),
            cameraAccessImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cameraAccessImageView.widthAnchor.constraint(equalToConstant: 20),
            cameraAccessImageView.heightAnchor.constraint(equalToConstant: 20),
            
            audioAccessButton.topAnchor.constraint(equalTo: cameraAccessButton.bottomAnchor, constant: 8.0),
            audioAccessButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            audioAccessImageView.leftAnchor.constraint(equalTo: audioAccessButton.rightAnchor, constant: 16.0),
            audioAccessImageView.centerYAnchor.constraint(equalTo: audioAccessButton.centerYAnchor),
            audioAccessImageView.widthAnchor.constraint(equalToConstant: 20),
            audioAccessImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}
