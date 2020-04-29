//
//  RecordingView.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit

class RecordingView: UIView {
    
    // MARK: - Properties
    
    let label = UILabel()
    let dotView = UIView()
    var timer: Timer!
    
    // MARK: - View Lifecycle
    
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
    
    // MARK: - Functions 
    
    private func setupViews() {
                
        translatesAutoresizingMaskIntoConstraints = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .cloud
        label.text = "Rec".capitalized
        addSubview(label)
        
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = .red
        addSubview(dotView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(recordingStarted), name: .startRecordingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recordingStoped), name: .stopRecordingNotification, object: nil)
    }
    
    @objc func recordingStarted() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            UIView.animate(withDuration: 1.0, animations: {
                self.dotView.alpha = 0.2
            }) { (finished) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.dotView.alpha = 1.0
                })
            }
        }
    }
    
    @objc func recordingStoped() {
        timer.invalidate()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            dotView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2),
            dotView.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 8.0),
            dotView.heightAnchor.constraint(equalToConstant: 10),
            dotView.widthAnchor.constraint(equalToConstant: 10)
        ])
        dotView.layer.cornerRadius = dotView.bounds.size.width/2
    }
}
