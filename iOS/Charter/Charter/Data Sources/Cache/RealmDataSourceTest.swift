//
//  RealmDataSourceTest.swift
//  Charter
//
//  Created by Matthew Palmer on 25/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
import RealmSwift
import Freddy
@testable import Charter

class RealmDataSourceTest: XCTestCase {
    var realm: Realm!
    
    override func setUp() {
        super.setUp()
        
        realm = setUpTestRealm()
    }
    
    func testRealmDataSource() {
        let shouldLoadEmails = expectationWithDescription("should load correct cached emails")
        
        let builder = EmailThreadRequestBuilder()
        builder.page = 5
        builder.pageSize = 2
        builder.mailingList = "swift-evolution"
        builder.inReplyTo = Either.Right(NSNull())
        builder.sort = [("date", false)]
        builder.onlyComplete = true
        
        let request = builder.build()
        let realmQuery = request.realmQuery
        
        XCTAssertEqual(realmQuery.page, 5)
        
        // Load in data
        let data = dataForJSONFile("EmailThreadResponse")
        let json = try! JSON(data: data)
        let emailList = try! json.array("_embedded", "rh:doc")
        let threads = emailList.map { try? Email.createFromJSON($0, inRealm: self.realm) }.flatMap { $0 }.sort { $0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970 }
        
        let dataSource = RealmDataSource(realm: realm)
        dataSource.getThreads(request) { (emails) -> Void in
            XCTAssertEqual([threads[8].id, threads[9].id], emails.map { $0.id })
            shouldLoadEmails.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
