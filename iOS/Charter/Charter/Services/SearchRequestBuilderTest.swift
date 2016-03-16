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
        
        // /charter/emails?filter={$text: {$search: 'Erica'}}&pagesize=50&sort_by={$meta: "textScore"}
        let parameters = builder.build().URLRequestQueryParameters
        XCTAssertEqual(parameters["filter"], "{$text:{$search:'Erica'}}")
        XCTAssertEqual(parameters["pagesize"], "50")
        XCTAssertEqual(parameters["sort_by"], "{$meta:'textScore'}")
    }
}
