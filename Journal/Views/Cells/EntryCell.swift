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
    var entryImageView = UIImageView()
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
            entryImageView.sd_setImage(with: URL(string: entry?.imageUrl ?? "")) { (image, error, type, url) in
            
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
        
        entryImageView.contentMode = .scaleAspectFill
        entryImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(entryImageView)
        
        videoLenghtLabel.textColor = .systemGray5
        videoLenghtLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        videoLenghtLabel.translatesAutoresizingMaskIntoConstraints = false
        entryImageView.addSubview(videoLenghtLabel)
        
        addSubview(shimmerView)
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        
        shimmerView.shimmeringAnimationOpacity = 0.5
        shimmerView.shimmeringSpeed = 80
        
        shimmerView.contentView = contentView
        shimmerView.isShimmering = true
        
        NSLayoutConstraint.activate([
            entryImageView.heightAnchor.constraint(equalTo: heightAnchor),
            entryImageView.widthAnchor.constraint(equalTo: widthAnchor),
            
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
            self.shimmerView.isShimmering = false
            player = AVPlayer(url:  videoUrl)
            player?.addObserver(self, forKeyPath: key, options: .new, context: nil)
        }
    }
    
    func createThumbnail(videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return UIImage(named: "ico_placeholder")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == key {
            if let duration = player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                if durationSeconds.isNaN { return }
                let secondsText = Int(durationSeconds) % 60
                let minutesText = String(format: "%02d", Int(durationSeconds) / 60)
                self.videoLenghtLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
}


import UIKit
import ImageIO
import Foundation

class ImageLoadOperation: Operation {

    var url: URL?
    var image: UIImage?
    
    init(url: URL?) {
        self.url = url
        super.init()
    }
    
    override func main() {
        let asset = AVAsset(url: url!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            self.image = thumbnail
        } catch {
            self.image = UIImage()
        }
    }
}
