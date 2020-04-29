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
    
    // MARK: - Properties
    
    lazy var cameraController = CameraController()
    lazy var mediaAccessView = MediaAccessView()
    lazy var cameraView = CameraView()
    private var player: AVPlayer!
    
    // MARK: - View Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        verifyCameraPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraController.startCaptureSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraController.stopCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    // MARK: - Functions
    
    func verifyCameraPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
//            mediaAccessView.removeFromSuperview()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    DispatchQueue.main.async {
                        self.mediaAccessView.isHidden = true
                    }
                } else {
                    //access denied
                    DispatchQueue.main.async {
                        self.mediaAccessView.isHidden = false
                    }
                }
            })
        }
    }
    
    
    func setupViews() {
        view.backgroundColor = .white
        
        cameraController.setUpCaptureSession()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        cameraView.session = cameraController.captureSession
        
        view.addSubview(mediaAccessView)
        view.addSubview(cameraView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestCameraAccess), name: .requestCameraNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestCameraRotation), name: .rotateCameraNotification, object: nil)
    }
    
    @objc func requestCameraRotation() {
        print("ROTATE")
        cameraController.switchCamera()
    }
    
    @objc func requestCameraAccess() {
        cameraController.setUpCaptureSession()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        cameraView.session = cameraController.captureSession
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            mediaAccessView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mediaAccessView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            cameraView.widthAnchor.constraint(equalTo: view.widthAnchor),
            cameraView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
