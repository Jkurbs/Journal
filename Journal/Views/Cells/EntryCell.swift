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
        
        NSLayoutConstraint.activate([
            shimmerView.widthAnchor.constraint(equalTo: widthAnchor),
            shimmerView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
        
        shimmerView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        shimmerView.shimmeringAnimationOpacity = 0.5
        shimmerView.shimmeringSpeed = 80
        
        shimmerView.contentView = contentView
        shimmerView.isShimmering = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
