//
//  EmailThreadRequestBuilderTest.swift
//  Charter
//
//  Created by Matthew Palmer on 21/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

class EmailThreadRequestBuilderTest: XCTestCase {
    func testEmailThreadRequestBuilder() {
        let builder = EmailThreadRequestBuilder()
        builder.inReplyTo = Either.Right(NSNull())
        builder.sort = [("date", false)]
        builder.pageSize = 25
        builder.page = 1
        builder.mailingList = "swift-users"
        
        let request = builder.build()
        let parameters = request.URLRequestQueryParameters
        XCTAssertEqual(parameters["filter"], "{inReplyTo:null,mailingList:'swift-users'}")
        XCTAssertEqual(parameters["sort"], "{date:-1}")
        XCTAssertEqual(parameters["pagesize"], "\(25)")
        XCTAssertEqual(parameters["page"], "\(1)")
        
        let realmQuery = request.realmQuery
        XCTAssertEqual(realmQuery.page, 1)
        XCTAssertEqual(realmQuery.pageSize, 25)
        XCTAssertEqual(realmQuery.predicate.predicateFormat, "inReplyTo == nil AND mailingList == \"swift-users\"")
        let sort = realmQuery.sort
        XCTAssertEqual(sort?.property, "date")
        XCTAssertEqual(sort?.ascending, false)
    }
}
