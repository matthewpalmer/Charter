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
        // filter={inReplyTo: null}&sort={date: -1}&pagesize=25&page=1
        let builder = EmailThreadRequestBuilder()
        builder.inReplyTo = Either.Right(NSNull())
        builder.sort = [("date", false)]
        builder.pageSize = 25
        builder.page = 1
        
        let request = builder.build()
        let parameters = request.URLRequestQueryParameters
        XCTAssertEqual(parameters["filter"], "{inReplyTo: null}")
        XCTAssertEqual(parameters["sort"], "{date: -1}")
        XCTAssertEqual(parameters["pagesize"], "\(25)")
        XCTAssertEqual(parameters["page"], "\(1)")
    }
}
