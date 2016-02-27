//
//  TestThreadService.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

class MockCacheDataSource: EmailThreadCacheDataSource {
    var emails: [Email] = []
    
    var cacheEmailAssertionBlock: ((emails: [NetworkEmail]) -> Void)?
    
    func getThreads(request: EmailThreadRequest, completion: [Email] -> Void) {
        completion(emails)
    }

    func cacheEmails(emails: [NetworkEmail]) throws {
        cacheEmailAssertionBlock?(emails: emails)
    }
}

class MockNetworkDataSource: EmailThreadNetworkDataSource {
    var emails: [NetworkEmail] = []
    
    func getThreads(request: EmailThreadRequest, completion: [NetworkEmail] -> Void) {
        completion(emails)
    }
}

class MockApplication: Application {
    var networkActivityIndicatorToggleCount = 0
    
    var networkActivityIndicatorVisible: Bool = false {
        didSet {
            networkActivityIndicatorToggleCount++
        }
    }
}

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
        
        service.getUncachedThreads(EmailThreadRequestBuilder().build()) { (uncachedEmails) -> Void in
            XCTAssertEqual(application.networkActivityIndicatorToggleCount, 2)
            XCTAssertEqual(application.networkActivityIndicatorVisible, false)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
