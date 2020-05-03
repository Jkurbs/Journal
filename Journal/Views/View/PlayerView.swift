//
//  PlayerView.swift
//  Journal
//
//  Created by Kerby Jean on 5/1/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import Shimmer
import AVFoundation
import BMPlayer


class PlayerView: UIView {

    let playButton = UIButton()
    let mediaButton = UIButton()
    let videoLenghtLabel = UILabel()
    let sentimentLabel = UILabel()
    let textView = UITextView()
    
    var player = BMPlayer()
    var playerLayer: AVPlayerLayer?

    static var id: String {
        return String(describing: self)
    }
    
    var entry: Entry? {
        didSet {
            configure(entry!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = 5.0
        
        player.translatesAutoresizingMaskIntoConstraints = false
        addSubview(player)
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .cloud
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            player.topAnchor.constraint(equalTo: topAnchor),
            player.widthAnchor.constraint(equalTo: widthAnchor),
            player.heightAnchor.constraint(equalTo: widthAnchor),
            player.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            textView.topAnchor.constraint(equalTo: player.bottomAnchor, constant: 8.0),
            textView.heightAnchor.constraint(equalTo: player.heightAnchor),
            textView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ entry: Entry) {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let docDir : URL = urls.first {
            let videoUrl = docDir.appendingPathComponent("\(entry.name ?? "").mov")
            let asset = BMPlayerResource(url: videoUrl)
            player.setVideo(resource: asset)
            player.layer.contentsGravity = .resizeAspectFill
            
            textView.text = entry.speech

            player.backBlock = { [unowned self] (isFullScreen) in
                if isFullScreen == true { return }
                
            }
        }
    }
}


