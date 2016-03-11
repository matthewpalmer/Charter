//
//  SnapshotTestCase.swift
//  Charter
//
//  Created by Matthew Palmer on 29/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
import SimulatorStatusMagic
import RealmSwift

class SnapshotTestCase: XCTestCase {
    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        SDStatusBarManager.sharedInstance().enableOverrides()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScreenshots() {
        // Note: before trying to record a screenshot, run the UI tests (Cmd + U on the CharterUITests scheme) to load the stub data into the default Realm. Make sure you clean the content and settings of the simulator.
        // This only needs to be done when recording new screenshots; when running the tests, the app will load the stub data into the realm itself.
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        snapshot("04MailingLists")
        tablesQuery.staticTexts["Swift Evolution"].tap()
        snapshot("01Threads")
        tablesQuery.staticTexts["Optional Binding Shorthand Syntax"].tap()
        snapshot("02Content")
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(0).staticTexts["•••"].tap()
        snapshot("03Quote")
        app.navigationBars["UIView"].buttons["Swift Evolution"].tap()
    }

}
