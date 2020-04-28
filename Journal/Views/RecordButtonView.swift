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
    }
    
    @objc private func startRecording() {
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurredEffectView.heightAnchor.constraint(equalTo: heightAnchor),
            blurredEffectView.widthAnchor.constraint(equalTo: widthAnchor),
            
            recordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            recordButton.heightAnchor.constraint(equalTo:heightAnchor, constant: -30),
            recordButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -30),
        ])
        recordButton.layer.cornerRadius = recordButton.bounds.size.width/2
        blurredEffectView.layer.cornerRadius = blurredEffectView.bounds.size.width/2
        blurredEffectView.clipsToBounds = true
    }
}
