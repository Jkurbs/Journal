//
//  EntriesViewController.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import SweetCurtain

class EntriesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: - Functions
    
    func setupViews() {
        view.backgroundColor = .blue
        view.layer.cornerRadius = 10.0
    }
}

// MARK: - CurtainDelegate
extension EntriesViewController: CurtainDelegate {
    
}
