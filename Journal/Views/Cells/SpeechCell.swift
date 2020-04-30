//
//  SpeechCell.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit

class SpeechCell: UICollectionViewCell {
    
    var textView = UITextView()
    
    var text: String? {
        didSet {
            textView.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .yellow
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .label
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalTo: heightAnchor),
            textView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

