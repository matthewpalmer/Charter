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
    func getThreads(request: CachedThreadRequest, completion: [Email] -> Void) {}

    func cacheEmails(emails: [NetworkEmail]) throws {}
}

private class Network: EmailThreadNetworkDataSource {
    func getThreads(request: UncachedThreadRequest, completion: [NetworkEmail] -> Void) {}
}

class ThreadsViewControllerDataSourceImplTest: XCTestCase {
    func testDataSource() {
        let shouldGetInitialCachedThreads = expectationWithDescription("should get initial cached threads")
        
        let shouldRefreshThreads = expectationWithDescription("should refresh threads when requested")
        let shouldMakeCorrectRequestOnRefresh = expectationWithDescription("should make correct reqeuest on refresh")
        
        let service = EmailThreadServiceMock(cacheDataSource: Cache(), networkDataSource: Network())
        
        let email1 = Email()
        email1.subject = "[swift-users] [Proposal] [Accepted] some subject"
        email1.date = NSDate(timeIntervalSince1970: 100000)
        email1.from = "Matthew Palmer"
        email1.descendants.appendContentsOf([Email(), Email(), Email()])
        service.cachedThreads = [email1]
        
        service.getCachedThreadsAssertionBlock = { (request: CachedThreadRequest) in
            let query = request.realmQuery
            XCTAssertEqual(query.predicate.predicateFormat, "inReplyTo == nil AND mailingList == \"swift-users\"")
            XCTAssertEqual(query.onlyComplete, true)
            XCTAssertEqual(query.page, 1)
            XCTAssertEqual(query.pageSize, 50)
            XCTAssertEqual(query.sort?.0, "date")
            XCTAssertEqual(query.sort?.1, false)
            
            shouldGetInitialCachedThreads.fulfill()
        }
        
        let labelService = LabelServiceImpl()
        
        let tableView = UITableView()
        let dataSource = ThreadsViewControllerDataSourceImpl(service: service, mailingList: MailingList.SwiftUsers.rawValue, labelService: labelService)
        dataSource.registerTableView(tableView)
        
        XCTAssertEqual(dataSource.tableView(tableView, numberOfRowsInSection: 0), 1)
        
        let cell = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! MessagePreviewTableViewCell
        XCTAssertEqual(cell.subjectLabel.text, "some subject")
         // Lower case because we do small caps
        XCTAssertEqual(cell.timeLabel.text, "2 jan")
        XCTAssertEqual(cell.nameLabel.text, email1.from.lowercaseString)
        XCTAssertEqual(cell.messageCountLabel.text, "3")
        
        print(email1.subject)
        let labels = cell.labelStackView.arrangedSubviews
        XCTAssertEqual((labels[0] as! UILabel).text, "proposal")
        XCTAssertEqual((labels[1] as! UILabel).text, "accepted")
        
        service.refreshCacheAssertionBlock = { (request: EmailThreadRequest) in
            let query = request.URLRequestQueryParameters
            
            XCTAssertEqual(query["page"], "1")
            XCTAssertEqual(query["filter"], "{inReplyTo:null,mailingList:\'swift-users\'}")
            XCTAssertEqual(query["pagesize"], "50")
            XCTAssertEqual(query["sort_by"], "-date")
            
            shouldMakeCorrectRequestOnRefresh.fulfill()
        }
        
        dataSource.refreshDataFromNetwork { (success) -> Void in
            shouldRefreshThreads.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testDataSourceForEmptyState() {
        let service = EmailThreadServiceMock(cacheDataSource: Cache(), networkDataSource: Network())
        let labelService = LabelServiceImpl()
        let tableView = UITableView()
        let dataSource = ThreadsViewControllerDataSourceImpl(service: service, mailingList: MailingList.SwiftUsers.rawValue, labelService: labelService)
        dataSource.registerTableView(tableView)
        
        XCTAssertEqual(dataSource.tableView(tableView, numberOfRowsInSection: 0), 1)
        
        let cell = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! NoThreadsTableViewCell
        XCTAssertEqual(cell.titleLabel.text, "No Messages")
        XCTAssertEqual(cell.subtitleLabel.text, "Pull to refresh…")
        
    }
}
