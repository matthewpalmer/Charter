//
//  Snapshot.swift
//  Charter
//
//  Created by Matthew Palmer on 7/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest

class Snapshot: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSnapshots() {
        
        let app = XCUIApplication()
        app.navigationBars["Mailing Lists"].staticTexts["Mailing Lists"].tap()
        
        let tablesQuery2 = app.tables
        let tablesQuery = tablesQuery2
        tablesQuery.staticTexts["Swift Dev"].tap()
        tablesQuery.staticTexts["CGPath cannot be found"].tap()
        tablesQuery2.cells.containingType(.StaticText, identifier:"Thomas Krajacic").childrenMatchingType(.TextView).element.tap()
        tablesQuery.staticTexts["•••"].tap()
        app.navigationBars["UIView"].buttons["Threads"].tap()
        
    }
    
}
