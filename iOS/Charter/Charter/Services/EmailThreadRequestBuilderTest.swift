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
        XCTAssertEqual(parameters["sort_by"], "-date")
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
    
    func testIdInQueries() {
        let builder = EmailThreadRequestBuilder()
        builder.idIn = ["one@test.com", "two@example.com", "three@example.com", "four@a.net"]
        builder.mailingList = "swift-dev"
        
        let request = builder.build()
        
        let parameters = request.URLRequestQueryParameters
        XCTAssertEqual(parameters["filter"], "{_id:{$in:['one@test.com','two@example.com','three@example.com','four@a.net']},mailingList:'swift-dev'}")
        
        let realm = request.realmQuery
        XCTAssertEqual(realm.predicate.predicateFormat, "mailingList == \"swift-dev\" AND id IN {\"one@test.com\", \"two@example.com\", \"three@example.com\", \"four@a.net\"}")
    }
    
    func testIdInGetsPercentEncoding() {

        let builder = EmailThreadRequestBuilder()
        builder.idIn = ["CA+Y5xYfqKR6yC2Q-G7D9N7FeY%3Dxs1x3frq%3D%3DsyGoqYpOcL9yrw@mail.gmail.com","CAA+bWKUPaPtN8sFiNzp+xrZV47iJdi9g_3hUrAiaG39-j7YPpg@mail.gmail.com","CAA+bWKXSTkAuFC+NTLPaO0XAOa09kUt5CNNNrGyoL+SZgf7ZhQ@mail.gmail.com","CACR_FB63_19+4uwtyUgnt7MQ6KY7NPCTS1p1K7r8Xw3AXRBmNw@mail.gmail.com","314A26E1-C235-4C68-81EE-18B2284CEC5A@lorentey.hu","CA+Y5xYcEiEvW8fT55UGT7gUEWUzW3e-cgf6UgbGjdJd7B1Dd1A@mail.gmail.com","CA+Y5xYcgdxbqo7cHR4KXdBXu6stncn4WVhBea9GroeFLJLy6gw@mail.gmail.com","DE386A8B-8454-4137-AB74-E29BD13C621C@architechies.com","CA+Y5xYcNqZTOCh5LZnM%3DY07_o8ShL-e_xe9+itHqMkgtR-dNtw@mail.gmail.com"]
        let request = builder.build()
        let parameters = request.URLRequestQueryParameters
        
        // Should percent escape the + sign (RESTHeart seems to be inconsistent about what needs to be URL encoded) because this symbol doesn't get URL encoded by NSURLComponents
        let expected = "{_id:{$in:['CA%2BY5xYfqKR6yC2Q-G7D9N7FeY%3Dxs1x3frq%3D%3DsyGoqYpOcL9yrw@mail.gmail.com','CAA%2BbWKUPaPtN8sFiNzp%2BxrZV47iJdi9g_3hUrAiaG39-j7YPpg@mail.gmail.com','CAA%2BbWKXSTkAuFC%2BNTLPaO0XAOa09kUt5CNNNrGyoL%2BSZgf7ZhQ@mail.gmail.com','CACR_FB63_19%2B4uwtyUgnt7MQ6KY7NPCTS1p1K7r8Xw3AXRBmNw@mail.gmail.com','314A26E1-C235-4C68-81EE-18B2284CEC5A@lorentey.hu','CA%2BY5xYcEiEvW8fT55UGT7gUEWUzW3e-cgf6UgbGjdJd7B1Dd1A@mail.gmail.com','CA%2BY5xYcgdxbqo7cHR4KXdBXu6stncn4WVhBea9GroeFLJLy6gw@mail.gmail.com','DE386A8B-8454-4137-AB74-E29BD13C621C@architechies.com','CA%2BY5xYcNqZTOCh5LZnM%3DY07_o8ShL-e_xe9%2BitHqMkgtR-dNtw@mail.gmail.com']}}"
        
        XCTAssertEqual(parameters["filter"], expected)
    }
}
