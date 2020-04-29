//
//  EntryCell.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import Shimmer 

class EntryCell: UICollectionViewCell {
    
    let shimmerView = FBShimmeringView()
    let imageView = UIImageView()
    var videoLenghtLabel = UILabel()
    
    static var id: String {
        return String(describing: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = 10.0

        addSubview(shimmerView)
        shimmerView.translatesAutoresizingMaskIntoConstraints = false

        shimmerView.shimmeringAnimationOpacity = 0.5
        shimmerView.shimmeringSpeed = 80

        shimmerView.contentView = contentView
        shimmerView.isShimmering = true
    
        videoLenghtLabel.text = "5:60"
        videoLenghtLabel.textColor = .cloud
        videoLenghtLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        videoLenghtLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(videoLenghtLabel)
        
        NSLayoutConstraint.activate([
            
            shimmerView.widthAnchor.constraint(equalTo: widthAnchor),
            shimmerView.heightAnchor.constraint(equalTo: heightAnchor),
   
            videoLenghtLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            videoLenghtLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8.0),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
