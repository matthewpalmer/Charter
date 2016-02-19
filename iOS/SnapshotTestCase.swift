//
//  Snapshot.swift
//  Charter
//
//  Created by Matthew Palmer on 7/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest

class SnapshotTestCase: XCTestCase {
        
    override func setUp() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSnapshots() {
        
        let app = XCUIApplication()
        app.navigationBars["Mailing Lists"].staticTexts["Mailing Lists"].tap()
        snapshot("04MailingLists")
        let tablesQuery2 = app.tables
        let tablesQuery = tablesQuery2
        tablesQuery.staticTexts["Swift Dev"].tap()
        snapshot("01ThreadsList")
        tablesQuery.staticTexts["CGPath cannot be found"].tap()
        snapshot("02Conversation")
        tablesQuery2.cells.containingType(.StaticText, identifier:"Thomas Krajacic").childrenMatchingType(.TextView).element.tap()
        tablesQuery.staticTexts["•••"].tap()
        snapshot("03Quote")
        app.navigationBars["UIView"].buttons["Threads"].tap()
        
    }
    
}
