//
//  LearnMoreViewController.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit

class LearnMoreViewController: UIViewController {
    
    let titleLabel = UILabel()
    let descriptionView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    func setupViews() {
        
        view.backgroundColor = .systemBackground
        
        titleLabel.text = "How Journal works"
        titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .semibold)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        descriptionView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        descriptionView.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.textColor = UIColor.label
        descriptionView.backgroundColor = .red
        view.addSubview(descriptionView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150.0),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0),
            descriptionView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
            descriptionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
}
