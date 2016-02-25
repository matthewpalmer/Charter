//
//  ThreadsViewControllerDataSourceTest.swift
//  Charter
//
//  Created by Matthew Palmer on 26/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

private class Cache: EmailThreadCacheDataSource {
    func getThreads(request: EmailThreadRequest, completion: [Email] -> Void) {}

    func cacheEmails(emails: [NetworkEmail]) throws {}
}

private class Network: EmailThreadNetworkDataSource {
    func getThreads(request: EmailThreadRequest, completion: [NetworkEmail] -> Void) {}
}

class ThreadsViewControllerDataSourceTest: XCTestCase {
    func testDataSource() {
        let shouldGetInitialCachedThreads = expectationWithDescription("should get initial cached threads")
        
        let shouldRefreshThreads = expectationWithDescription("should refresh threads when requested")
        let shouldMakeCorrectRequestOnRefresh = expectationWithDescription("should make correct reqeuest on refresh")
        
        let service = EmailThreadServiceMock(cacheDataSource: Cache(), networkDataSource: Network())
        
        let email1 = Email()
        email1.subject = "some subject"
        email1.date = NSDate(timeIntervalSince1970: 100000)
        email1.from = "Matthew Palmer"
        service.cachedThreads = [email1]
        
        service.getCachedThreadsAssertionBlock = { (request: EmailThreadRequest) in
            let query = request.realmQuery
            XCTAssertEqual(query.predicate.predicateFormat, "inReplyTo == nil AND mailingList == \"swift-users\"")
            XCTAssertEqual(query.onlyComplete, true)
            XCTAssertEqual(query.page, 1)
            XCTAssertEqual(query.pageSize, 50)
            XCTAssertEqual(query.sort?.0, "date")
            XCTAssertEqual(query.sort?.1, false)
            
            shouldGetInitialCachedThreads.fulfill()
        }
        
        let tableView = UITableView()
        let dataSource = ThreadsViewControllerDataSource(tableView: tableView, service: service, mailingList: MailingList.SwiftUsers.rawValue)
        
        XCTAssertEqual(dataSource.numberOfSectionsInTableView(tableView), 1)
        XCTAssertEqual(dataSource.tableView(tableView, numberOfRowsInSection: 0), 1)
        
        let cell = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! MessagePreviewTableViewCell
        XCTAssertEqual(cell.subjectLabel.text, email1.subject)
        XCTAssertEqual(cell.timeLabel.text, "2 Jan")
        XCTAssertEqual(cell.nameLabel.text, email1.from)
        
        service.getUncachedThreadsAssertionBlock = { (request: EmailThreadRequest) in
            let query = request.URLRequestQueryParameters
            
            XCTAssertEqual(query["page"], "1")
            XCTAssertEqual(query["filter"], "{inReplyTo:null,mailingList:\'swift-users\'}")
            XCTAssertEqual(query["pagesize"], "50")
            XCTAssertEqual(query["sort"], "{date:-1}")
            
            shouldMakeCorrectRequestOnRefresh.fulfill()
        }
        
        dataSource.refreshDataFromNetwork { (success) -> Void in
            shouldRefreshThreads.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testDataSourceForEmptyState() {
        let service = EmailThreadServiceMock(cacheDataSource: Cache(), networkDataSource: Network())
        let tableView = UITableView()
        let dataSource = ThreadsViewControllerDataSource(tableView: tableView, service: service, mailingList: MailingList.SwiftUsers.rawValue)
        
        XCTAssertEqual(dataSource.tableView(tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(dataSource.numberOfSectionsInTableView(tableView), 1)
        
        let cell = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! NoThreadsTableViewCell
        XCTAssertEqual(cell.titleLabel.text, "No Messages")
        XCTAssertEqual(cell.subtitleLabel.text, "Pull to refresh…")
        
    }
}
