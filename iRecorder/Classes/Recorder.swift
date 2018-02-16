//
//  Recorder.swift
//  iRecorder
//
//  Created by Titouan Van Belle on 09.02.18.
//  Copyright © 2018 Fyber GmbH. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMediaIO

enum RecordQuality: String {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

struct RecordSettings
{
    let quality: RecordQuality
    let deviceName: String?
    let deviceId: String?
    let output: String
    let force: Bool

    init(quality: RecordQuality, deviceName: String, output: String, force: Bool = false)
    {
        self.quality = quality
        self.deviceName = deviceName
        self.output = output
        self.deviceId = nil
        self.force = force
    }

    init(quality: RecordQuality, deviceId: String, output: String, force: Bool = false)
    {
        self.quality = quality
        self.deviceId = deviceId
        self.output = output
        self.deviceName = nil
        self.force = force
    }
}

struct Recorder
{
    let xRecord_Bridge: XRecord_Bridge = XRecord_Bridge();
    let capture = Capture()

    func stopRecording()
    {
        print("Stopping recording...")
        capture.stop()
        xRecord_Bridge.stopScreenCapturePlugin();

        print("Done")
        exit(EX_OK);
    }

    func startRecording(settings: RecordSettings)
    {
        xRecord_Bridge.startScreenCapturePlugin()
        capture.setQuality(settings.quality.rawValue)

        var setDeviceClosure: () -> (Bool) = { return false }

        if let deviceName = settings.deviceName {
            setDeviceClosure = { return self.capture.setDeviceByName(deviceName) }
        } else if let deviceId = settings.deviceId {
            setDeviceClosure = { return self.capture.setDeviceById(deviceId) }
        }

        if !setDeviceClosure() {
            print("Cannot find device with name. Please unplug  and plug again the device")
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureDeviceWasConnected, object: nil, queue:nil) { (notification) in
                print("Device found")
                let device = notification.object as! AVCaptureDevice
                if settings.deviceName == device.localizedName || settings.deviceId == device.uniqueID {
                    setDeviceClosure()

                    if settings.force {
                        self.deleteFile(output: settings.output)
                    }

                    self.capture.start(settings.output)
                }
            }
        } else {
            capture.start(settings.output)
        }
    }

    private func deleteFile(output: String)
    {
        guard FileManager.default.fileExists(atPath: output) else {
            return
        }

        do {
            try FileManager.default.removeItem(atPath: outFile.value!)
        } catch let error as NSError {
            print("Error overwriting existing file (\(error)).")
            exit(EX_SOFTWARE)
        }
    }
}
