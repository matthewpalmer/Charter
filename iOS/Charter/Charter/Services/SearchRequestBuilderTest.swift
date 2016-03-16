//
//  SearchRequestBuilderTest.swift
//  Charter
//
//  Created by Matthew Palmer on 16/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

class SearchRequestBuilderTest: XCTestCase {
    func testSearchRequestBuilder() {
        let builder = SearchRequestBuilder()
        builder.text = "Erica"
        builder.mailingList = "swift-evolution"
        
        let parameters = builder.build().URLRequestQueryParameters
        XCTAssertEqual(parameters["filter"], "{$text:{$search:'Erica'},mailingList:'swift-evolution'}")
        XCTAssertEqual(parameters["pagesize"], "50")
        XCTAssertEqual(parameters["sort_by"], "{$meta:'textScore'}")
    }
}
