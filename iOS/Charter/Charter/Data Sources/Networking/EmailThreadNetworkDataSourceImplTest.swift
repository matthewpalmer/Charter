//
//  EmailThreadNetworkDataSourceImplTest.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Charter

class EmailThreadNetworkDataSourceImplTest: XCTestCase {
    var realm: Realm!
    
    override func setUp() {
        super.setUp()
        realm = setUpTestRealm()
    }

    func testGetThreads() {
        let getsThreads = expectationWithDescription("getsThreads")
        let correctRequest = expectationWithDescription("correctRequest")
        
        let dataTask = NSURLSessionDataTaskMock()
        dataTask.completionArguments.data = dataForJSONFile("EmailThreadResponse")
        
        let mockSession = NetworkingSessionMock(dataTask: dataTask)
        
        mockSession.assertionBlockForRequest = { request in
            XCTAssertEqual(request.allHTTPHeaderFields!["Authorization"], "Basic Y2xpZW50OmFHLWNpckYtT2ctZlUt")
            XCTAssertEqual(request.URL?.absoluteString, "http://162.243.241.218:8080/charter/emails?page=1&sort=%7Bdate:%20-1%7D&pagesize=25&filter=%7BinReplyTo:%20null%7D")
            correctRequest.fulfill()
        }
        
        let network = EmailThreadNetworkDataSourceImpl(username: nil, password: nil, session: mockSession, realm: realm)
        let builder = EmailThreadRequestBuilder()
        builder.inReplyTo = Either.Right(NSNull())
        builder.sort = [("date", false)]
        builder.pageSize = 25
        builder.page = 1
        
        network.getThreads(builder.build()) { (emails) -> Void in
            XCTAssertEqual(emails.count, 25)
            getsThreads.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
