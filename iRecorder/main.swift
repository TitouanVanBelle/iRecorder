//
//  main.swift
//  DeviceDetector
//
//  Created by Titouan Van Belle on 08.02.18.
//  Copyright © 2018 Titouan Van Belle. All rights reserved.
//

import Cocoa
import Foundation


// Command Line part

let cli = CommandLine()

let name =    StringOption(shortFlag: "n", longFlag: "name", required: false, helpMessage: "Device Name.")
let id =      StringOption(shortFlag: "i", longFlag: "id", required: false, helpMessage: "Device ID.")
let outFile = StringOption(shortFlag: "o", longFlag: "out", required: true, helpMessage: "Output File.")
let quality = StringOption(shortFlag: "q", longFlag: "quality", required: false, helpMessage: "Recording quality (low, medium, high - defaults to high)")
let list =    BoolOption(shortFlag: "l", longFlag: "list", helpMessage: "List available capture devices.")
let force =   BoolOption(shortFlag: "f", longFlag: "force", helpMessage: "Overwrite existing file.")
let help =    BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

cli.addOptions(name, id, outFile, quality, list, force, help)

let (success, error) = cli.parse()

if !success {
    print(error!)
    cli.printUsage()
    exit(EX_USAGE)
}


// Command Line part is done
// Conditions are met to start recording

var outValue = outFile.value!
var forceValue = force.value
var settings: RecordSettings
var recordQuality: RecordQuality = .high

if let qualityValue = quality.value {
    if let q = RecordQuality(rawValue: qualityValue) {
        recordQuality = q
    }
}

if let deviceName = name.value {
    settings = RecordSettings(quality: recordQuality, deviceName: deviceName, output: outValue, force: forceValue)
} else if let deviceId = id.value {
    settings = RecordSettings(quality: recordQuality, deviceId: deviceId, output: outValue, force: forceValue)
} else {
    cli.printUsage()
    exit(EX_USAGE)
}

let recorder = Recorder()

Trap.handle(.interrupt) { (code) -> (Void) in
    print("Interrupt")
    recorder.stopRecording()
}

Trap.handle(.abort) { (code) -> (Void) in
    print("Abort")
    recorder.stopRecording()
}

Trap.handle(.termination) { (code) -> (Void) in
    print("Termination")
    recorder.stopRecording()
}

Trap.handle(.kill) { (code) -> (Void) in
    print("Kill")
    recorder.stopRecording()
}

recorder.startRecording(settings: settings)

RunLoop.main.run()
