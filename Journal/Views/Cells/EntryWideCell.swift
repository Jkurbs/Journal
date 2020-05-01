//
//  EntryWideCell.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import Shimmer
import SDWebImage
import AVFoundation

class EntryWideCell: UICollectionViewCell {
    
    let playButton = UIButton()
    let mediaButton = UIButton()
    let videoLenghtLabel = UILabel()
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var path: String?
    var timeObserver: Any?
    var slider = UISlider()
    
    var pauseImage: UIImage!
    var playImage: UIImage!
    
    static var id: String {
        return String(describing: self)
    }
    
    var entry: Entry? {
        didSet {
            configure(entry?.name ?? "")
        }
    }
    
    
    var isPlaying = false
    var key = "currentItem.loadedTimeRanges"
    
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
        
        let pauseImageConfiguration = UIImage.SymbolConfiguration(scale: .small)
        let pauseButtonImage = UIImage(systemName: "pause.fill", withConfiguration: pauseImageConfiguration)!
        pauseImage = pauseButtonImage.withTintColor(.cloud, renderingMode: .alwaysOriginal)
        
        let playImageConfiguration = UIImage.SymbolConfiguration(scale: .small)
        let playButtonImage = UIImage(systemName: "play.fill", withConfiguration: playImageConfiguration)!
        playImage = playButtonImage.withTintColor(.cloud, renderingMode: .alwaysOriginal)
        
        
        mediaButton.translatesAutoresizingMaskIntoConstraints = false
        mediaButton.setImage(pauseImage, for: .normal)
        mediaButton.addTarget(self, action: #selector(pauseVideo), for: .touchUpInside)
        addSubview(mediaButton)

        
        videoLenghtLabel.text = "5:60"
        videoLenghtLabel.textColor = .systemGray5
        videoLenghtLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        videoLenghtLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(videoLenghtLabel)
        
        slider.tintColor = .lightText
        slider.setThumbImage(UIImage() , for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            self.updateSlider(elapsedTime: elapsedTime)
        })
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == key {
            print("OBSERVING")
            isPlaying = true
        }
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
            slider.centerXAnchor.constraint(equalTo: centerXAnchor),
            slider.widthAnchor.constraint(equalTo: widthAnchor, constant: -88.0),

            mediaButton.bottomAnchor.constraint(equalTo: slider.bottomAnchor, constant: 0.0),
            mediaButton.rightAnchor.constraint(equalTo: slider.leftAnchor, constant: -8.0),
            mediaButton.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
            mediaButton.widthAnchor.constraint(equalToConstant: 25),
            mediaButton.heightAnchor.constraint(equalToConstant: 25),
            
            videoLenghtLabel.bottomAnchor.constraint(equalTo: slider.bottomAnchor, constant: 0.0),
            videoLenghtLabel.leftAnchor.constraint(equalTo: slider.rightAnchor, constant: 8.0),
            videoLenghtLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
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
            player?.isMuted = false
            playerLayer = AVPlayerLayer(player: player)
            contentView.contentMode = .scaleAspectFill
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            contentView.layer.addSublayer(playerLayer!)
            
            self.playerLayer?.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height - 40)
            player?.play()
            
            player?.addObserver(self, forKeyPath: key, options: .new, context: nil)
            
            
            let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
                self.updateSlider(elapsedTime: elapsedTime)
            })
        }
    }
    
    @objc func pauseVideo() {
        if isPlaying {
            print("ITS PLAYING")
            player?.pause()
            mediaButton.setImage(playImage, for: .normal)
        } else {
            print("NOT PLAYING")
            player?.play()
            mediaButton.setImage(pauseImage, for: .normal)
        }
        _ = isPlaying != isPlaying
    }
    
    @objc func playVideo() {
        player?.play()
        playButton.isHidden = true
        mediaButton.isHidden = false
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }
    
    func updateSlider(elapsedTime: CMTime) {
        let playerDuration = playerItemDuration()
        if CMTIME_IS_INVALID(playerDuration) {
            slider.minimumValue = 0.0
            return
        }
        let duration = Float(CMTimeGetSeconds(playerDuration))
        if duration.isFinite && duration > 0 {
            slider.minimumValue = 0.0
            slider.maximumValue = duration
            let time = Float(CMTimeGetSeconds(elapsedTime))
            slider.setValue(time, animated: true)
        }
    }
    
    private func playerItemDuration() -> CMTime {
        let thePlayerItem = player?.currentItem
        if thePlayerItem?.status == .readyToPlay {
            return thePlayerItem!.duration
        }
        return CMTime.invalid
    }
}
