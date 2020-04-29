//
//  Notification+String.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let requestCameraNotification = Notification.Name("requestCameraNotification")
    static let requestAudioNotification = Notification.Name("requestAudioNotification")
    static let startRecordingNotification = Notification.Name("startRecordingNotification")
    static let stopRecordingNotification = Notification.Name("stopRecordingNotification")
    static let rotateCameraNotification = Notification.Name("rotateCameraNotification")
    static let dimCameraNotification = Notification.Name("dimCameraNotification")

}
