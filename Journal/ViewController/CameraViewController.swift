//
//  CameraViewController.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    lazy var cameraController = CameraController()
    lazy var cameraView = CameraView()
    private var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Functions
    
    func setupViews() {
        
        view.backgroundColor = .white
        view.addSubview(cameraView)
        
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        cameraView.session = cameraController.captureSession
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            cameraView.widthAnchor.constraint(equalTo: view.widthAnchor),
            cameraView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
