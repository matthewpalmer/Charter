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
    
    func testLoadPrecachedEmails() {
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
    
    func networkEmailsInThread() -> [NetworkEmail] {
        let data = dataForJSONFile("EmailThreadResponse")
        let json = try! JSON(data: data)
        let emailList = try! json.array("_embedded", "rh:doc")
        let fromNetwork = emailList.map { try! NetworkEmail.createFromJSON($0) }
        return fromNetwork
    }
    
    func testCacheNetworkEmailsUpdateShouldOccur() {
        let fromNetwork = networkEmailsInThread()
        let dataSource = RealmDataSource(realm: realm)
        
        // Get some data into the cache
        try! dataSource.cacheEmails(fromNetwork)
        
        let numberOfEmails = 639
        XCTAssertEqual(realm.objects(Email).count, numberOfEmails)
                
        let moreCompleteEmailIncomingToCache: NetworkEmail = NetworkEmail(id: "m27fi94f92.fsf@eno.apple.com", from: "someone", mailingList: "swift-evolution", content: "content", archiveURL: "archive", date: NSDate(), subject: "subject", inReplyTo: nil, references: ["m2d1s2bhnf.fsf@eno.apple.com"], descendants: ["blah_blah@blah.com"])
        
        try! dataSource.cacheEmails([moreCompleteEmailIncomingToCache])
        
        XCTAssertEqual(realm.objects(Email).count, numberOfEmails + 1) // Increase by one because there is one previously unknown descendant
        let updated = realm.objects(Email).filter("id == %@", "m27fi94f92.fsf@eno.apple.com").first!
        XCTAssertEqual(updated.content, "content")
        XCTAssertEqual(updated.archiveURL, "archive")
        XCTAssertEqual(updated.subject, "subject")
    }
    
    func testCacheNetworkEmailsWhenUpdateShouldNotOccur() {
        let dataSource = RealmDataSource(realm: realm)
        
        let fullExists = NetworkEmail(id: "one@example.com", from: "one", mailingList: "swift-evolution", content: "content 1", archiveURL: "archive url", date: NSDate(), subject: "subject", inReplyTo: nil, references: [], descendants: [])
        
        try! dataSource.cacheEmails([fullExists])
        
        let partialByReference = NetworkEmail(id: "two@example.com", from: "two", mailingList: "swift-evolution", content: "content", archiveURL: "archive url", date: NSDate(), subject: "sb", inReplyTo: nil, references: [fullExists.id], descendants: [])
        try! dataSource.cacheEmails([partialByReference])
        
        let first = realm.objects(Email).filter("id == %@", fullExists.id).first!
        XCTAssertEqual(first.from, fullExists.from)
        XCTAssertEqual(first.mailingList, fullExists.mailingList)
        XCTAssertEqual(first.content, fullExists.content)
        XCTAssertEqual(first.archiveURL, fullExists.archiveURL)
    }
}
