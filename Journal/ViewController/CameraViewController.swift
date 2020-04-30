//
//  CameraViewController.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import SweetCurtain
import AVFoundation

class CameraViewController: UIViewController {
    
    // MARK: - Properties
    
    lazy var cameraController = CameraController()
    lazy var mediaAccessView = MediaAccessView()
    lazy var cameraView = CameraView()
    private var player: AVPlayer!
    
    // MARK: - View Lifecycle
    
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
        view.backgroundColor = .black
        cameraController.setUpCaptureSession()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        cameraView.session = cameraController.captureSession
        
        view.addSubview(mediaAccessView)
        view.addSubview(cameraView)
        addObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(startRecording), name: .startRecordingNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopRecording), name: .stopRecordingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestCameraAccess), name: .requestCameraNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestCameraRotation), name: .rotateCameraNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeViewAlpha(_:)), name: .dimCameraNotification, object: nil)
    }
    
    @objc func changeViewAlpha(_ notification: Notification) {
        if let info = notification.userInfo, let alpha = info["alpha"] as? CGFloat {
            if alpha > 0.7 {
                UIView.animate(withDuration: 0.5) {
                    self.cameraView.alpha = 0.0
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.cameraView.alpha = 1.0
                }
            }
        }
    }
    
    @objc func startRecording() {
        cameraController.startRecording()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.curtainController?.moveCurtain(to: .min, animated: true)
        }
    }
    
    @objc func stopRecording() {
        // Debug
        cameraController.stopRecording()
        curtainController?.moveCurtain(to: .mid, animated: true)
        DataService.shared.saveEtries(name: cameraController.fileName ?? "", speech: cameraController.speech ?? "", sentimen: "", date: CachedDateFormattingHelper.shared.formatTodayDate(), completion: { result in
            if let _ = try? result.get() {
                DispatchQueue.main.async {
                    //TODO: - show alert to user
                }
            }
        })

    }
    
    @objc func requestCameraRotation() {
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
