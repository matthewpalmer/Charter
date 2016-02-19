//
//  MailingListParserTests.swift
//  MailingListParserTests
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest

class MailingListParserTests: XCTestCase {
    var parser: MailingListParser!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = NSBundle(forClass: MailingListMessageParserTests.self)
        let file = bundle.URLForResource("List-1", withExtension: nil)
        let data = NSData(contentsOfURL: file!)
        let list = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String

        parser = MailingListParser(string: list)
    }
    
    func testSplitEmails() {
        let expected = [
            "From dturnbull at gmail.com  Mon Jan 25 02:59:50 2016\nFrom: dturnbull at gmail.com (David Turnbull)\nDate: Mon, 25 Jan 2016 00:59:50 end-0800\nSubject: [swift-users] Need help with compile times (type inference?)\nIn-Reply-To: <6DB7FDEB-7F38-47F9-84D2-F068578F3501@apple.com>\nReferences: <CANEjtCBEpdsna8-zbU1wgNu4zOnmT5-TJoQQU8+ey_-9YeYNSw@mail.gmail.com>\n<F575F007-45D1-4D42-93FB-61DBA1FFEC6D@apple.com>\n<CANEjtCCHd4WPg13wtM_++i10kjHpXcF6mpkGfOZHPP1MYgO7bg@mail.gmail.com>\n<71B631F2-DE83-4796-8C3B-5638191947B3@apple.com>\n<CANEjtCD=WRyVHEEovsShkrtTMyg5e-94PizZ-yzTOd2M1buNZA@mail.gmail.com>\n<6DB7FDEB-7F38-47F9-84D2-F068578F3501@apple.com>\nMessage-ID: <CANEjtCDg5mCCwB5xqvshGeLvx4wdNyZtLwN+7GLNwAqKYNhE8g@mail.gmail.com>\n\nOn Sun, Jan 24, 2016 at 9:55 PM, Chris Lattner <clattner at apple.com> wrote:\n\n> Are you willing/able to share the code for your project?  That definitely\n> sounds strange,\n>\n\nSoitenly: https://github.com/AE9RB/SwiftGL\n\nThe 28,000 lines of loader code are fine. The 6,000 lines of math libraries\nare the problem.\n\nI\'m sure it\'s something to do with prototypes and generics. You can change\nin Types.swift:\npublic protocol FloatingPointScalarType : ScalarType\nto:\npublic protocol FloatingPointScalarType : ScalarType, FloatingPointType\nand make the problem a bit worse. This is something I\'d actually like to\nuse, except I don\'t because a few \"where constraints\" do what I need\nwithout the build slowdown.\n\nSwift 2.1 or 2.2-dev doesn\'t make a difference. The C++ compiler I bench\nagainst is also llvm. The compiled binaries are truly fast (with WMO). It\'s\nonly the development process that\'s too slow because of build times.\n\n-David \"nyuk nyuk nyuk\" Turnbull",
            
            "From v_ds_dt at 163.com  Mon Jan 25 04:34:50 2016\nFrom: v_ds_dt at 163.com (CosynPa)\nDate: Mon, 25 Jan 2016 18:34:50 +0800\nSubject: [swift-users] How to express an optional is always not nil under\ncertain conditions\nMessage-ID: <56A5FA4A.5040406@163.com>\n\nFor example, I have a function that set some optional value:\n\nfunc foo() {\nif xxx {\nswitch yyy {\ncase .c1:\nsomeOptional = nil\ncase .c2:\nsomeOptional = 5\n}\n} else {\nsomeOptional = nil\n}\n}\n\nLater I want to do something with the optional value. And I know the\noptional is always not nil when xxx is satisfied and yyy is in c2 case,\nso I just use force unwrapping.\n\nfunc bar() {\nif xxx {\nswitch yyy {\ncase .c1:\ndoSomething1()\ncase .c2:\ndoSomethingWithValue(someOptional !)// force unwrapping, not very good\n}\n} else {\ndoSomething2()\n}\n}\n\nBut this is not very good, since you can\'t tell from the code why the\noptional is not nil, and if the function foo is changed, you are not\naware of the fact that the force unwrapping is no longer valid. So is\nthere some better solution?",
            
            "From jon889 at me.com  Mon Jan 25 07:01:48 2016\nFrom: jon889 at me.com (Jonathan Bailey)\nDate: Mon, 25 Jan 2016 13:01:48 +0000\nSubject: [swift-users] try? with a function that returns an optional\nMessage-ID: <2FA36C98-FBCA-4F27-9706-77DF38BF747C@me.com>\n\nIn the language guide on the apple website, https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html#//apple_ref/doc/uid/TP40014097-CH42-ID542\n\nIt says the following assignments to x and y are equivalent:\nfunc someThrowingFunction() throws -> Int { ... }\nlet x = try? someThrowingFunction()\n// x has type `Int?`\n\nlet y: Int?\ndo {\ny = try someThrowingFunction()\n} catch {\ny = nil\n}\n\nHowever this isn’t the case if someThrowingFunction also returns an optional, say:\n\nfunc someThrowingFunction() throws -> Int? { ... }\n\nThe type of x would be `Int??`, but the type of y is still `Int?`, is there some way to make the `try?` return an `Int?` instead of a double optional, which is not very helpful.\n\nThanks,\nJonathan"
        ]
        
        let actual = parser.emails
        
        
        XCTAssertEqual(expected, actual)
    }
    
    func testLongList() {
        let bundle = NSBundle(forClass: MailingListMessageParserTests.self)
        let file = bundle.URLForResource("List-2", withExtension: nil)
        let data = NSData(contentsOfURL: file!)
        let list = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        
        let parser = MailingListParser(string: list)
        
        XCTAssertEqual(parser.emails.count, 338)
    }
    
    func testLongList2() {
        let bundle = NSBundle(forClass: MailingListMessageParserTests.self)
        let file = bundle.URLForResource("List-3", withExtension: nil)
        let data = NSData(contentsOfURL: file!)
        let list = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        
        let parser = MailingListParser(string: list)
        
        XCTAssertEqual(parser.emails.count, 411)
    }
    
    func testWeirdList() {
        let bundle = NSBundle(forClass: MailingListMessageParserTests.self)
        let file = bundle.URLForResource("List-4", withExtension: nil)
        let data = NSData(contentsOfURL: file!)
        let list = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        
        parser = MailingListParser(string: list)
        
        let thorston = parser.emails[2]
        let messageParser = MailingListMessageParser(string: thorston)
        
    }
}
