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
        
    
    var isSeekInProgress = false
    var chaseTime = CMTime.zero
    var playerCurrentItemStatus:AVPlayerItem.Status = .unknown
    
    
    func stopPlayingAndSeekSmoothlyToTime(newChaseTime:CMTime) {
            player?.pause()
            if CMTimeCompare(newChaseTime, chaseTime) != 0 {
                chaseTime = newChaseTime;
                if !isSeekInProgress {
                    trySeekToChaseTime()
                }
            }
        }
     
        func trySeekToChaseTime() {
            if playerCurrentItemStatus == .unknown {
                // wait until item becomes ready (KVO player.currentItem.status)
            }
            else if playerCurrentItemStatus == .readyToPlay  {
                actuallySeekToTime()
            }
        }
     
        func actuallySeekToTime() {
            isSeekInProgress = true
            let seekTimeInProgress = chaseTime
            player?.seek(to: seekTimeInProgress, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (isFinished:Bool) -> Void in
     
                if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                    self.isSeekInProgress = false
                    self.mediaButton.setImage(self.playImage, for: .normal)
                }
                else
                {
                    self.trySeekToChaseTime()
                }
            })
        }

    
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
        layer.cornerRadius = 5.0
        
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
        
        videoLenghtLabel.text = "0:00"
        videoLenghtLabel.textColor = .systemGray5
        videoLenghtLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        videoLenghtLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(videoLenghtLabel)
        
        
        let thumbImageConfiguration = UIImage.SymbolConfiguration(scale: .small)
        let thumbButtonImage = UIImage(systemName: "circle.fill", withConfiguration: thumbImageConfiguration)!
        let thumbImage = thumbButtonImage.withTintColor(.cloud, renderingMode: .alwaysOriginal)
        
        slider.tintColor = .lightText
        slider.setThumbImage(thumbImage , for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
            slider.centerXAnchor.constraint(equalTo: centerXAnchor),
            slider.widthAnchor.constraint(equalTo: widthAnchor, constant: -88.0),

            mediaButton.bottomAnchor.constraint(equalTo: slider.bottomAnchor, constant: 0.0),
            mediaButton.rightAnchor.constraint(equalTo: slider.leftAnchor, constant: 0.0),
            mediaButton.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
            mediaButton.widthAnchor.constraint(equalToConstant: 45),
            mediaButton.heightAnchor.constraint(equalToConstant: 45),
            
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
            contentView.layer.addSublayer(playerLayer!)
            
            playerLayer?.videoGravity = .resizeAspectFill
            
            self.playerLayer?.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height/2)
            self.playerLayer?.position.y = center.y
            self.playerLayer?.position.x = center.x

            
            player?.addObserver(self, forKeyPath: key, options: .new, context: nil)
            player?.play()
            slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        }
    }
    
    @objc func pauseVideo() {
        if isPlaying {
            player?.pause()
            mediaButton.setImage(playImage, for: .normal)
        } else {
            player?.play()
            mediaButton.setImage(pauseImage, for: .normal)
        }
       isPlaying = !isPlaying
    }
    
    @objc func playVideo() {
        player?.play()
        playButton.isHidden = true
        mediaButton.isHidden = false
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        player?.seek(to: .zero)
        mediaButton.setImage(playImage, for: .normal)
    }
    
    @objc func handleSliderChange() {
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(slider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            self.stopPlayingAndSeekSmoothlyToTime(newChaseTime: seekTime)
//
//            player?.seek(to: seekTime, completionHandler: { _ in
//                // Perhaps do something later
//            })
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == key {
            isPlaying = true
            if let duration = player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                let interval = CMTime(value: 1, timescale: 2)
                player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (time) in
                    let seconds = CMTimeGetSeconds(time)
                    let ramainder = durationSeconds - seconds
                    let secondsText = Int(ramainder) % 60
                    let minutesText = String(format: "%02d", Int(ramainder) / 60)
                    self.slider.value = Float(seconds/durationSeconds)
                    self.videoLenghtLabel.text = "\(minutesText):\(secondsText)"
                })
            }
        }
    }
    
    deinit {
        player?.removeTimeObserver(self)
    }
}
