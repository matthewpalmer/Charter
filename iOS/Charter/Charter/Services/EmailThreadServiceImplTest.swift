//
//  TestThreadService.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

class EmailThreadServiceImplTest: XCTestCase {
    func testCompletionCalledWhenRetrievingFromCache() {
        let expectation = expectationWithDescription("should complete with emails")
        
        let cache = MockCacheDataSource()
        let email = Email()
        email.id = "one"
        cache.emails.append(email)
        
        let network = MockNetworkDataSource()
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        service.getCachedThreads(EmailThreadRequestBuilder().build()) { (emails) -> Void in
            XCTAssertEqual(emails.first!, email)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testNetworkAndCaching() {
        let expectation = expectationWithDescription("should get emails from network and cache them")
        
        let cache = MockCacheDataSource()
        let email1 = Email()
        email1.id = "one"
        cache.emails = [email1]
        
        let network = MockNetworkDataSource()
        let email2 = NetworkEmail(id: "two", from: "from", mailingList: "ml", content: "con", archiveURL: "ar", date: NSDate(), subject: "sub", inReplyTo: nil, references: [], descendants: [])
        network.emails = [email2]
        
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        let application = MockApplication()
        service.application = application
        
        cache.cacheEmailAssertionBlock = { (emails: [NetworkEmail]) in
            XCTAssertEqual(emails.first!.id, network.emails.first!.id)
        }
        
        service.refreshCache(EmailThreadRequestBuilder().build()) { (uncachedEmails) -> Void in
            XCTAssertEqual(application.networkActivityIndicatorToggleCount, 2)
            XCTAssertEqual(application.networkActivityIndicatorVisible, false)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testGetUncachedThreads() {
        let expectation = expectationWithDescription("should get uncached threads")
        
        let cache = MockCacheDataSource()
        let email1 = Email()
        email1.id = "one"
        
        let email3 = Email()
        email3.id = "three"
        
        cache.emails = [email1, email3]
        
        cache.cacheEmailAssertionBlock = { (emails: [NetworkEmail]) in
            let email2 = Email()
            email2.id = "two"
            cache.emails = [email1, email2, email3]
        }
        
        func networkEmailWithId(id: String) -> NetworkEmail {
            return NetworkEmail(id: id, from: "", mailingList: "", content: "", archiveURL: nil, date: NSDate(), subject: "", inReplyTo: nil, references: [], descendants: [])
        }
        
        let network = MockNetworkDataSource()
        network.emails = [networkEmailWithId("two"), networkEmailWithId("three"), networkEmailWithId("one")]
        
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        let application = MockApplication()
        service.application = application
        
        service.getUncachedThreads(EmailThreadRequestBuilder().build()) { (emails) -> Void in
            XCTAssertEqual(application.networkActivityIndicatorToggleCount, 2)
            XCTAssertEqual(application.networkActivityIndicatorVisible, false)
            
            // Should match ordering from network, not the cache
            XCTAssertEqual(emails[0].id, "two")
            XCTAssertEqual(emails[1].id, "three")
            XCTAssertEqual(emails[2].id, "one")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
