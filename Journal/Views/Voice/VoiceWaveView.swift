//
//  VoiceWaveView.swift
//  Journal
//
//  Created by Kerby Jean on 4/29/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import PXSiriWave

class VoiceWaveView: UIView {
    
    let waveView = PXSiriWave()
    
    var decibel: CGFloat? {
        didSet {
            waveView.update(withLevel: decibel ?? 0.0)
        }
    }
    
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
        waveView.translatesAutoresizingMaskIntoConstraints = false
        waveView.frequency = 1.5;
        waveView.amplitude = 0.01;
        waveView.intensity = 0.3;
        waveView.configure()
        addSubview(waveView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            waveView.heightAnchor.constraint(equalTo: heightAnchor),
            waveView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
}
