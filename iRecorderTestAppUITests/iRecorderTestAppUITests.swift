//
//  iRecorderTestAppUITests.swift
//  iRecorderTestAppUITests
//
//  Created by Titouan Van Belle on 16.02.18.
//  Copyright © 2018 Fyber GmbH. All rights reserved.
//

import XCTest

class iRecorderTestAppUITests: XCTestCase {

    let mockServer = MockServer()

    func start()
    {

    }

    func stop()
    {

    }

    override func setUp()
    {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        mockServer.startRecording(out: "test.mp4")

        XCUIApplication().launch()
    }
    
    override func tearDown()
    {
        mockServer.stopRecording()
        XCUIApplication().terminate()
        super.tearDown()
    }
    
    func testExample()
    {
        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons["Second"].tap()
        tabBarsQuery.buttons["First"].tap()
        tabBarsQuery.buttons["Second"].tap()
        tabBarsQuery.buttons["First"].tap()
    }
}
