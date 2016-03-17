//
//  TestUtilities.swift
//  Charter
//
//  Created by Matthew Palmer on 25/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Charter

let config = Realm.Configuration(path: "./test-realm", inMemoryIdentifier: "test-realm")

extension XCTestCase {
    func setUpTestRealm() -> Realm {
        let realm = try! Realm(configuration: config)
        
        try! realm.write {
            realm.deleteAll()
        }
        
        return realm
    }
    
    func testBundle() -> NSBundle {
        return NSBundle(forClass: self.dynamicType)
    }
    
    func dataForJSONFile(file: String) -> NSData {
        let fileURL = testBundle().URLForResource(file, withExtension: "json")!
        return NSData(contentsOfURL: fileURL)!
    }
}

class NSURLSessionDataTaskMock : NSURLSessionDataTask {
    var completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void?)?
    var completionArguments: (data: NSData?, response: NSURLResponse?, error: NSError?)
    
    override func resume() {
        completionHandler?(completionArguments.data, completionArguments.response, completionArguments.error)
    }
}

class NetworkingSessionMock: NetworkingSession {
    let dataTask: NSURLSessionDataTaskMock
    
    var assertionBlockForRequest: ((NSURLRequest) -> Void)?
    
    init(dataTask: NSURLSessionDataTaskMock) {
        self.dataTask = dataTask
    }
    
    func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        assertionBlockForRequest?(request)
        
        dataTask.completionHandler = completionHandler
        return dataTask
    }
}

class EmailThreadServiceMock: EmailThreadService {
    var cachedThreads: [Email] = []
    var uncachedThreads: [Email] = []
    
    var getCachedThreadsAssertionBlock: ((request: CachedThreadRequest) -> Void)?
    var refreshCacheAssertionBlock: ((request: EmailThreadRequest) -> Void)?
    var getUncachedThreadsAssertionBlock: ((request: UncachedThreadRequest) -> Void)?
    
    required init(cacheDataSource: EmailThreadCacheDataSource, networkDataSource: EmailThreadNetworkDataSource) {}
    
    func getCachedThreads(request: CachedThreadRequest, completion: [Email] -> Void) {
        getCachedThreadsAssertionBlock?(request: request)
        completion(cachedThreads)
    }
    
    func refreshCache(request: EmailThreadRequest, completion: [Email] -> Void) {
        refreshCacheAssertionBlock?(request: request)
        completion(uncachedThreads)
    }
    
    func getUncachedThreads(request: UncachedThreadRequest, completion: [Email] -> Void) {
        getUncachedThreadsAssertionBlock?(request: request)
        completion(uncachedThreads)
    }
}

class MockCacheDataSource: EmailThreadCacheDataSource {
    var emails: [Email] = []
    
    var cacheEmailAssertionBlock: ((emails: [NetworkEmail]) -> Void)?
    
    func getThreads(request: CachedThreadRequest, completion: [Email] -> Void) {
        completion(emails)
    }
    
    func cacheEmails(emails: [NetworkEmail]) throws {
        cacheEmailAssertionBlock?(emails: emails)
    }
}

class MockNetworkDataSource: EmailThreadNetworkDataSource {
    var emails: [NetworkEmail] = []
    
    func getThreads(request: UncachedThreadRequest, completion: [NetworkEmail] -> Void) {
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
