//
//  EntryCell.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import Shimmer
import SDWebImage
import AVFoundation

class EntryCell: UICollectionViewCell {
    
    let shimmerView = FBShimmeringView()
    let imageView = UIImageView()
    var videoLenghtLabel = UILabel()
    var playerView = UIView()
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var path: String?
    var timeObserver: Any?
    
    var key = "currentItem.loadedTimeRanges"
    
    static var id: String {
        return String(describing: self)
    }
    
    var entry: Entry? {
        didSet {
            imageView.sd_setImage(with: URL(string: entry?.imageUrl ?? "")) { (image, error, type, url) in
                self.shimmerView.isShimmering = false
            }
            configure(entry?.name ?? "")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = 2.0
        
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        videoLenghtLabel.text = "5:60"
        videoLenghtLabel.textColor = .systemGray5
        videoLenghtLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        videoLenghtLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(videoLenghtLabel)
        
        addSubview(shimmerView)
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        
        shimmerView.shimmeringAnimationOpacity = 0.5
        shimmerView.shimmeringSpeed = 80
        
        shimmerView.contentView = contentView
        shimmerView.isShimmering = true
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            
            shimmerView.widthAnchor.constraint(equalTo: widthAnchor),
            shimmerView.heightAnchor.constraint(equalTo: heightAnchor),
            
            videoLenghtLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            videoLenghtLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8.0),
        ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ videoName: String) {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let docDir : URL = urls.first {
            let videoUrl = docDir.appendingPathComponent("\(videoName).mov")
            player = AVPlayer(url:  videoUrl)
//            player?.addObserver(self, forKeyPath: key, options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == key {
            if let duration = player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                let secondsText = Int(durationSeconds) % 60
                let minutesText = String(format: "%02d", Int(durationSeconds) / 60)
                self.videoLenghtLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
}
