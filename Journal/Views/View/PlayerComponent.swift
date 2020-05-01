//
//  PlayerComponent.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit

class PlayerComponent: UIView {
    
    let mediaButton = UIButton()
    let videoLenghtLabel = UILabel()
    let slider = UISlider()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let mediaImageConfiguration = UIImage.SymbolConfiguration(scale: .small)
//        let mediaButtonImage = UIImage(systemName: "pause.fill", withConfiguration: mediaImageConfiguration)!
//        let image = mediaButtonImage.withTintColor(.cloud, renderingMode: .alwaysOriginal)
//        mediaButton.translatesAutoresizingMaskIntoConstraints = false
//        mediaButton.setImage(image, for: .normal)
//        mediaButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
//        addSubview(mediaButton)
//        
//        videoLenghtLabel.text = "5:60"
//        videoLenghtLabel.textColor = .systemGray5
//        videoLenghtLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
//        videoLenghtLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(videoLenghtLabel)
//        
//        slider.tintColor = .lightText
//        slider.setThumbImage(UIImage() , for: .normal)
//        slider.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(slider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

