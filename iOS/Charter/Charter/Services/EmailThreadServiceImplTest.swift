//
//  TestThreadService.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

class StubThread: EmailThread {
    let messageID: String
    let from: String
    let date: NSDate
    let subject: String
    let replies: [EmailThread]
    let mailingList: String
    
    init(messageID: String, from: String, date: NSDate, subject: String, replies: [EmailThread], mailingList: String) {
        self.messageID = messageID
        self.from = from
        self.date = date
        self.subject = subject
        self.replies = replies
        self.mailingList = mailingList
    }
}

class MockEmailThreadCacheDataSource: EmailThreadCacheDataSource {
    private var threads: [EmailThread]
    
    init(threads: [EmailThread]) {
        self.threads = threads
    }
    
    func getThreads() -> [EmailThread] {
        return threads
    }
    
    func cacheThreads(threads: [EmailThread], completion: Void -> Void) {
        self.threads.appendContentsOf(threads)
        completion()
    }
}

class MockEmailThreadNetworkDataSource: EmailThreadNetworkDataSource {
    private let threads: [EmailThread]
    
    init(threads: [EmailThread]) {
        self.threads = threads
    }
    
    func getThreads(completion: [EmailThread] -> Void) {
        completion(threads)
    }
}

class EmailThreadServiceImplTest: XCTestCase {
    func assertThreadsListsMatch(actual: [EmailThread], expected: [EmailThread]) {
        zip(actual, expected)
            .forEach { XCTAssertEqual($0.0.messageID, $0.1.messageID) }

    }
    
    func testGetCachedThreads() {
        let thread3: EmailThread = StubThread(messageID: "1.2", from: "c", date: NSDate(), subject: "1.2 msg", replies: [], mailingList: "swift")
        let thread2: EmailThread = StubThread(messageID: "1.1", from: "b", date: NSDate(), subject: "1.1 msg", replies: [], mailingList: "swift")
        let thread1: EmailThread = StubThread(messageID: "1", from: "a", date: NSDate(), subject: "a msg", replies: [thread2, thread3], mailingList: "swift")
        
        let cache = MockEmailThreadCacheDataSource(threads: [thread1])
        let network = MockEmailThreadNetworkDataSource(threads: [])
        
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        service.getCachedThreads { (threads: [EmailThread]) in
            XCTAssertEqual(threads[0].messageID, thread1.messageID)
            self.assertThreadsListsMatch(threads[0].replies, expected: [thread2, thread3])
        }
    }
    
    func testNetworkThreads() {
        let localThread: EmailThread = StubThread(messageID: "local-1", from: "a", date: NSDate(), subject: "local", replies: [], mailingList: "swift")
        
        let networkThread: EmailThread = StubThread(messageID: "network-1", from: "b", date: NSDate(), subject: "remote", replies: [], mailingList: "swift")
        
        let cache = MockEmailThreadCacheDataSource(threads: [localThread])
        let network = MockEmailThreadNetworkDataSource(threads: [networkThread])
        
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        
        service.getUncachedThreads { (threads) -> Void in
            self.assertThreadsListsMatch(threads, expected: [localThread, networkThread])
        }
    }
}
