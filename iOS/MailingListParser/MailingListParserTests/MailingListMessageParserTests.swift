//
//  MailingListMessageParserTests.swift
//  MailingListParser
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest

class MailingListMessageParserTests: XCTestCase {
    var message: String!
    var parser: MailingListMessageParser!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = NSBundle(forClass: MailingListMessageParserTests.self)
        let file = bundle.URLForResource("Message-1", withExtension: nil)
        let data = NSData(contentsOfURL: file!)
        
        message = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        parser = MailingListMessageParser(string: message)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFields() {
        XCTAssertEqual(parser.from, "jon889 at me.com (Jonathan Bailey)")
        XCTAssertEqual(parser.date, "Mon, 25 Jan 2016 15:54:37 +0000")
        XCTAssertEqual(parser.subject, "[swift-users] try? with a function that returns an optional")
        XCTAssertEqual(parser.inReplyTo, "<CAMA6uOAhMv1SAPRe=KcD15kYTmJjNNnDWtG+zBVJbXswNLMZGw@mail.gmail.com>")
        XCTAssertEqual(parser.references, "<2FA36C98-FBCA-4F27-9706-77DF38BF747C@me.com> <CAMA6uOAhMv1SAPRe=KcD15kYTmJjNNnDWtG+zBVJbXswNLMZGw@mail.gmail.com>")
        XCTAssertEqual(parser.messageID, "<A52D5CCD-E51B-488F-B915-8795231FFEB9@me.com>")
    }
    
    func testContentString() {
        let content = parser.contentString
        let expected = "So it would be legal to change the type of y in the second example to `Int??`\n\nDoes that mean when assigning optionals, it will unwrap, check if it\'s nill and assign nil, else assign the original value? This seems kind of pointless to just assigning the complete optional\n\n\n> On 25 Jan 2016, at 15:49, Svein Halvor Halvorsen <svein.h at lvor.halvorsen.cc> wrote:\n>\n> This is exactly according to the documentation.\n> In your first example `someThrowingFunction` returns an `Int`, so `y` is defined as an `Int?`.\n> In the second example `someThrowingFunction` returns an `Int?`, so `y` should be an `Int??`\n>\n> However, since you didn\'t update the definition of `y` in your second example, the if branch either assigns an `Int?` to an `Int?`, which is legal, and may be nil, or it explicitly sets it to nil, which is also legal. Thus, effectively unwrapping the nested optionals.\n>\n> Yu could also apply a `flatMap` to the nested optional, like so:\n>\n> let x = (try? someThrowingFunction())?.flatMap({$0})\n>\n> I\'m not sure if it\'s more readable, though.\n>\n>\n> 2016-01-25 14:01 GMT+01:00 Jonathan Bailey via swift-users <swift-users at swift.org>:\n>> In the language guide on the apple website, https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html#//apple_ref/doc/uid/TP40014097-CH42-ID542\n>>\n>> It says the following assignments to x and y are equivalent:\n>> func someThrowingFunction() throws -> Int { ... }\n>> let x = try? someThrowingFunction()\n>> // x has type `Int?`\n>>\n>> let y: Int?\n>> do {\n>>     y = try someThrowingFunction()\n>> } catch {\n>>     y = nil\n>> }\n>>\n>> However this isn’t the case if someThrowingFunction also returns an optional, say:\n>>\n>> func someThrowingFunction() throws -> Int? { ... }\n>>\n>> The type of x would be `Int??`, but the type of y is still `Int?`, is there some way to make the `try?` return an `Int?` instead of a double optional, which is not very helpful.\n>>\n>> Thanks,\n>> Jonathan\n>>\n>>\n>> _______________________________________________\n>> swift-users mailing list\n>> swift-users at swift.org\n>> https://lists.swift.org/mailman/listinfo/swift-users\n>>\n>"
        
        XCTAssertEqual(content, expected)
    }
    
    func testAdapter() {
        let actual = MailingListMessageParserAdapter(mailingListMessageParser: parser).mailingListMessage!
        
        let expectedHeaders = MailingListMessageHeaders(
            from: "jon889 at me.com (Jonathan Bailey)",
            date: "Mon, 25 Jan 2016 15:54:37 +0000",
            subject: "[swift-users] try? with a function that returns an optional",
            inReplyTo: "CAMA6uOAhMv1SAPRe=KcD15kYTmJjNNnDWtG+zBVJbXswNLMZGw@mail.gmail.com",
            references: ["2FA36C98-FBCA-4F27-9706-77DF38BF747C@me.com", "CAMA6uOAhMv1SAPRe=KcD15kYTmJjNNnDWtG+zBVJbXswNLMZGw@mail.gmail.com"],
            messageID: "A52D5CCD-E51B-488F-B915-8795231FFEB9@me.com")
        
        let expectedContent = "So it would be legal to change the type of y in the second example to `Int??`\n\nDoes that mean when assigning optionals, it will unwrap, check if it\'s nill and assign nil, else assign the original value? This seems kind of pointless to just assigning the complete optional\n\n\n> On 25 Jan 2016, at 15:49, Svein Halvor Halvorsen <svein.h at lvor.halvorsen.cc> wrote:\n>\n> This is exactly according to the documentation.\n> In your first example `someThrowingFunction` returns an `Int`, so `y` is defined as an `Int?`.\n> In the second example `someThrowingFunction` returns an `Int?`, so `y` should be an `Int??`\n>\n> However, since you didn\'t update the definition of `y` in your second example, the if branch either assigns an `Int?` to an `Int?`, which is legal, and may be nil, or it explicitly sets it to nil, which is also legal. Thus, effectively unwrapping the nested optionals.\n>\n> Yu could also apply a `flatMap` to the nested optional, like so:\n>\n> let x = (try? someThrowingFunction())?.flatMap({$0})\n>\n> I\'m not sure if it\'s more readable, though.\n>\n>\n> 2016-01-25 14:01 GMT+01:00 Jonathan Bailey via swift-users <swift-users at swift.org>:\n>> In the language guide on the apple website, https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html#//apple_ref/doc/uid/TP40014097-CH42-ID542\n>>\n>> It says the following assignments to x and y are equivalent:\n>> func someThrowingFunction() throws -> Int { ... }\n>> let x = try? someThrowingFunction()\n>> // x has type `Int?`\n>>\n>> let y: Int?\n>> do {\n>>     y = try someThrowingFunction()\n>> } catch {\n>>     y = nil\n>> }\n>>\n>> However this isn’t the case if someThrowingFunction also returns an optional, say:\n>>\n>> func someThrowingFunction() throws -> Int? { ... }\n>>\n>> The type of x would be `Int??`, but the type of y is still `Int?`, is there some way to make the `try?` return an `Int?` instead of a double optional, which is not very helpful.\n>>\n>> Thanks,\n>> Jonathan\n>>\n>>\n>> _______________________________________________\n>> swift-users mailing list\n>> swift-users at swift.org\n>> https://lists.swift.org/mailman/listinfo/swift-users\n>>\n>"
        
        let expected = MailingListMessage(headers: expectedHeaders, content: expectedContent)
        
        XCTAssertEqual(expected, actual)
    }
    
    func testThorsten() {
        let bundle = NSBundle(forClass: MailingListMessageParserTests.self)
        let file = bundle.URLForResource("Message-2", withExtension: nil)
        let data = NSData(contentsOfURL: file!)
        
        message = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        parser = MailingListMessageParser(string: message)
        
        XCTAssertEqual(parser.subject, "[swift-evolution] Proposal: Pattern Matching Partial Function (#111)")
    }
}
