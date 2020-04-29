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
    
    var decibel: Float? {
        didSet {
            DispatchQueue.main.async {
                self.waveView.update(withLevel: CGFloat(self.decibel ?? 0.0))
            }
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
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false 
        waveView.translatesAutoresizingMaskIntoConstraints = false
        waveView.frequency = 1.5;
        waveView.amplitude = 0.01;
        waveView.intensity = 0.3;
        waveView.configure()
        waveView.backgroundColor = .darkness
        addSubview(waveView)
        
        Timer.scheduledTimer(withTimeInterval: 0.11, repeats: true) { (timer) in
            self.waveView.update(withLevel: 0.1)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(test), name: NSNotification.Name("test2"), object: nil)
    }
    
    @objc func test(_ notification: Notification) {
        if let info = notification.userInfo, let decibel = info["decibel"] as? Float {
            self.decibel = decibel
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            waveView.heightAnchor.constraint(equalTo: heightAnchor),
            waveView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
}
