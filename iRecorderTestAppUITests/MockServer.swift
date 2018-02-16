//
//  MockServer.swift
//  iRecorderTestAppUITests
//
//  Created by Titouan Van Belle on 16.02.18.
//  Copyright © 2018 Fyber GmbH. All rights reserved.
//

import Foundation

struct Settings {
    let hostIP = "192.168.1.13"
    let port = 3000
    let deviceName = "tito"
}

struct MockServer
{
    let settings = Settings()

    func startRecording(out: String)
    {
        print("Start recording!")
        let urlString = "http://\(settings.hostIP):\(settings.port)/startRecording?out=\(out)&device=\(settings.deviceName)"
        request(urlString: urlString)
    }

    func stopRecording()
    {
        print("Stop recording!")
        let urlString = "http://\(settings.hostIP):\(settings.port)/stopRecording"
        request(urlString: urlString)
    }

    func request(urlString: String)
    {
        let url = URL(string: urlString)

        print("Sending request to \(urlString)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            print("Request sent")
        }

        task.resume()
    }
}

