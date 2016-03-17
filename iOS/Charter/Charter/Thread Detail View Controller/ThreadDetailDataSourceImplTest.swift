//
//  ThreadDetailDataSourceImplTest.swift
//  Charter
//
//  Created by Matthew Palmer on 27/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

/*
Thread:

e1
    e2
        e3
    e4 // This will move up when we sort by date
*/

func constructEmails() -> [Email] {
    let dateComponents = NSDateComponents()
    dateComponents.year = 2016
    dateComponents.month = 2
    dateComponents.day = 27
    dateComponents.hour = 12
    dateComponents.minute = 12
    
    let e1 = Email()
    e1.id = "1"
    e1.subject = "Thread"
    e1.from = "Matt"
    e1.date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    e1.content = "This is some content"
    
    let e2 = Email()
    e2.id = "2"
    e2.subject = "Re: Thread"
    e2.from = "Jess"
    dateComponents.day = 28
    e2.date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    e2.content = "Replying to some content"
    
    let e3 = Email()
    e3.id = "3"
    e3.subject = "Re: Re: Thread"
    e3.from = "Sam"
    dateComponents.day = 29
    e3.date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    e3.content = "Replying to a reply to Replying to some content"
    
    let e4 = Email()
    e4.id = "4"
    e4.subject = "Re: Thread"
    e4.from = "Martha"
    dateComponents.day = 24
    e4.date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    e4.content = "I am e4, Replying to some content"
    
    // Construct the thread
    e1.inReplyTo = nil
    e2.inReplyTo = e1
    e3.inReplyTo = e2
    e4.inReplyTo = e1
    
    e1.descendants.appendContentsOf([e2, e3, e4])
    e2.descendants.appendContentsOf([e3, e4])
    e3.descendants.appendContentsOf([e4])
    
    return [e1, e2, e3, e4]
}

class ThreadDetailDataSourceImplTest: XCTestCase {
    let emailThread = constructEmails()
    
    func testCellConstruction() {
        let cache = MockCacheDataSource()
        let network = MockNetworkDataSource()
        let service = EmailThreadServiceMock(cacheDataSource: cache, networkDataSource: network)
        service.cachedThreads = [emailThread[0]]
        service.uncachedThreads = [emailThread[0], emailThread[1], emailThread[2], emailThread[3]]
        
        let dataSource = ThreadDetailDataSourceImpl(service: service, rootEmail: emailThread[0], codeBlockParser: SwiftCodeBlockParser())
        let tableView = UITableView()
        dataSource.registerTableView(tableView)
        
        let formatter = EmailFormatter()
        
        let cell1 = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! FullEmailMessageTableViewCell
        XCTAssertEqual(cell1.nameLabel.text, emailThread[0].from.lowercaseString)
        XCTAssertEqual(cell1.dateLabel.text, formatter.formatDate(emailThread[0].date).lowercaseString)
        XCTAssertEqual(cell1.indentationLevel, 0)
        
        // These should be sorted by date (so email 4 comes before email 2)
        
        let cell2 = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! FullEmailMessageTableViewCell
        XCTAssertEqual(cell2.nameLabel.text, emailThread[3].from.lowercaseString)
        XCTAssertEqual(cell2.dateLabel.text, formatter.formatDate(emailThread[3].date).lowercaseString)
        XCTAssertEqual(cell2.indentationLevel, 1)
        
        let cell3 = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as! FullEmailMessageTableViewCell
        XCTAssertEqual(cell3.nameLabel.text, emailThread[1].from.lowercaseString)
        XCTAssertEqual(cell3.dateLabel.text, formatter.formatDate(emailThread[1].date).lowercaseString)
        XCTAssertEqual(cell3.indentationLevel, 1)
        
        let cell4 = dataSource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 3, inSection: 0)) as! FullEmailMessageTableViewCell
        XCTAssertEqual(cell4.nameLabel.text, emailThread[2].from.lowercaseString)
        XCTAssertEqual(cell4.dateLabel.text, formatter.formatDate(emailThread[2].date).lowercaseString)
        XCTAssertEqual(cell4.indentationLevel, 2)
    }
}
