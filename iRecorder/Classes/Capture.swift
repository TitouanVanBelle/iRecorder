//
//  capture.swift
//  xrecord
//
//  Created by Patrick Meenan on 2/26/15.
//  Copyright (c) 2015 WPO Foundation. All rights reserved.
//

import Foundation
import AVFoundation

class Capture: NSObject, AVCaptureFileOutputRecordingDelegate
{
    var session : AVCaptureSession!
    var input : AVCaptureDeviceInput?
    var output : AVCaptureMovieFileOutput!
    var started : Bool = false
    var finished : Bool = false
    var captureDevices: [AVCaptureDevice] {
        return AVCaptureDevice.devices()
    }

    override init()
    {
        super.init()

        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.low

        // All of this shit makes it work on iOS
        var prop = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))

        var allow : UInt32 = 1
        let dataSize : UInt32 = 4
        let zero : UInt32 = 0
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &prop, zero, nil, dataSize, &allow)
    }

    func setQuality(_ quality: String!)
    {
        if (quality == "low") {
            session.sessionPreset = AVCaptureSession.Preset.low;
        } else if (quality == "medium") {
            session.sessionPreset = AVCaptureSession.Preset.medium;
        } else if (quality == "high") {
            session.sessionPreset = AVCaptureSession.Preset.high;
        }
    }

    @discardableResult
    func setDeviceByName(_ name: String!) -> Bool
    {
        for captureDevice in captureDevices {
            if captureDevice.localizedName == name {
                var err : NSError? = nil
                do {
                    input = try AVCaptureDeviceInput(device: captureDevice)
                } catch let error as NSError {
                    err = error
                    input = nil
                }
                if err != nil {
                    return true
                }
            }
        }

        return false
    }

    @discardableResult
    func setDeviceById(_ id: String!) -> Bool
    {
        for captureDevice in captureDevices {
            if captureDevice.uniqueID == id {
                var err : NSError? = nil
                do {
                    input = try AVCaptureDeviceInput(device: captureDevice)
                } catch let error as NSError {
                    err = error
                    input = nil
                }
                if err != nil {
                    return true
                }
            }
        }

        return false
    }

    @discardableResult
    func start(_ file: String!) -> Bool
    {
        if session.canAddInput(self.input!) {
            session.addInput(self.input!)
            output = AVCaptureMovieFileOutput()

            if session.canAddOutput(output) {
                session.addOutput(output)
                session.startRunning()
                print("Starting to record to file: \(file)")
                output.startRecording(to: URL(fileURLWithPath: file), recordingDelegate: self)
                started = true
            }
        }

        return started
    }
    
    func stop()
    {
        guard started else {
            print("Recording has not started")
            return
        }

        output.stopRecording()
        session.stopRunning()
    }

    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!)
    {
        NSLog("captureOutput Started callback");
        started = true
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!)
    {
        NSLog("captureOutput Finished callback")
        finished = true
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {

    }

}
