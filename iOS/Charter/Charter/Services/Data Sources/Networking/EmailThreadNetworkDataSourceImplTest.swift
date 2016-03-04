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
    override func setUp() {
        super.setUp()
    }

    func testGetThreads() {
        let getsThreads = expectationWithDescription("getsThreads")
        let correctRequest = expectationWithDescription("correctRequest")
        
        let dataTask = NSURLSessionDataTaskMock()
        dataTask.completionArguments.data = dataForJSONFile("EmailThreadResponse")
        
        let mockSession = NetworkingSessionMock(dataTask: dataTask)
        
        mockSession.assertionBlockForRequest = { request in
            XCTAssertEqual(request.allHTTPHeaderFields!["Authorization"], "Basic Y2xpZW50OmFHLWNpckYtT2ctZlUt")
            
            // We can't guarantee the ordering of the query parameters.
            let expected = "http://charter.ws:8080/charter/emails?sort_by=-date&page=1&pagesize=25&filter=%7BinReplyTo:null%7D".characters.sort()
            let actual = request.URL!.absoluteString.characters.sort()
            
            XCTAssertEqual(expected, actual)
            correctRequest.fulfill()
        }
        
        let network = EmailThreadNetworkDataSourceImpl(username: nil, password: nil, session: mockSession)
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
    
    func testGetSubThreads() {
        let getsThreads = expectationWithDescription("getsThreads")
        let correctRequest = expectationWithDescription("correctRequest")
        
        let dataTask = NSURLSessionDataTaskMock()
        dataTask.completionArguments.data = dataForJSONFile("SubThreadResponse")
        
        let mockSession = NetworkingSessionMock(dataTask: dataTask)
        mockSession.assertionBlockForRequest = { request in
            // This is an important assertion: make sure the URL gets properly (but not necessarily spec compliant-ly...) URL encoded for RESTHeart
            // We can't guarantee the ordering of the query parameters.
            let expectedURL = "http://charter.ws:8080/charter/emails?pagesize=1000&filter=%7B_id:%7B$in:%5B'CA%2BY5xYfqKR6yC2Q-G7D9N7FeY%3Dxs1x3frq%3D%3DsyGoqYpOcL9yrw@mail.gmail.com','CAA%2BbWKUPaPtN8sFiNzp%2BxrZV47iJdi9g_3hUrAiaG39-j7YPpg@mail.gmail.com','CAA%2BbWKXSTkAuFC%2BNTLPaO0XAOa09kUt5CNNNrGyoL%2BSZgf7ZhQ@mail.gmail.com','CACR_FB63_19%2B4uwtyUgnt7MQ6KY7NPCTS1p1K7r8Xw3AXRBmNw@mail.gmail.com','314A26E1-C235-4C68-81EE-18B2284CEC5A@lorentey.hu','CA%2BY5xYcEiEvW8fT55UGT7gUEWUzW3e-cgf6UgbGjdJd7B1Dd1A@mail.gmail.com','CA%2BY5xYcgdxbqo7cHR4KXdBXu6stncn4WVhBea9GroeFLJLy6gw@mail.gmail.com','DE386A8B-8454-4137-AB74-E29BD13C621C@architechies.com','CA%2BY5xYcNqZTOCh5LZnM%3DY07_o8ShL-e_xe9%2BitHqMkgtR-dNtw@mail.gmail.com'%5D%7D%7D&page=1".characters.sort()
            XCTAssertEqual(request.URL!.absoluteString.characters.sort(), expectedURL)
            correctRequest.fulfill()
        }
        
        
        let network = EmailThreadNetworkDataSourceImpl(username: nil, password: nil, session: mockSession)
        let builder = EmailThreadRequestBuilder()
        builder.idIn = ["CA+Y5xYfqKR6yC2Q-G7D9N7FeY=xs1x3frq==syGoqYpOcL9yrw@mail.gmail.com","CAA+bWKUPaPtN8sFiNzp+xrZV47iJdi9g_3hUrAiaG39-j7YPpg@mail.gmail.com","CAA+bWKXSTkAuFC+NTLPaO0XAOa09kUt5CNNNrGyoL+SZgf7ZhQ@mail.gmail.com","CACR_FB63_19+4uwtyUgnt7MQ6KY7NPCTS1p1K7r8Xw3AXRBmNw@mail.gmail.com","314A26E1-C235-4C68-81EE-18B2284CEC5A@lorentey.hu","CA+Y5xYcEiEvW8fT55UGT7gUEWUzW3e-cgf6UgbGjdJd7B1Dd1A@mail.gmail.com","CA+Y5xYcgdxbqo7cHR4KXdBXu6stncn4WVhBea9GroeFLJLy6gw@mail.gmail.com","DE386A8B-8454-4137-AB74-E29BD13C621C@architechies.com","CA+Y5xYcNqZTOCh5LZnM=Y07_o8ShL-e_xe9+itHqMkgtR-dNtw@mail.gmail.com"]
        
        builder.pageSize = 1000
        builder.page = 1
        
        network.getThreads(builder.build()) { (emails) -> Void in
            XCTAssertEqual(emails.count, 9)
            getsThreads.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
