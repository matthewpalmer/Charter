//
//  EmailFormatterTest.swift
//  Charter
//
//  Created by Matthew Palmer on 26/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

class EmailFormatterTest: XCTestCase {
    func testFormatSubject() {
        let formatter = EmailFormatter()
        
        XCTAssertEqual(formatter.formatSubject("[swift-evolution] Anonymous Enums (Updated)"), "Anonymous Enums (Updated)")
        
        XCTAssertEqual(formatter.formatSubject("[swift-evolution] [Review] SE-0030 Property Behaviors "), "[Review] SE-0030 Property Behaviors")
        
        XCTAssertEqual(formatter.formatSubject("[swift-evolution] RFC: Proposed rewrite of Unmanaged<T>"), "RFC: Proposed rewrite of Unmanaged<T>")
    }
    
    func testFormatName() {
        let formatter = EmailFormatter()
        
        // normal
        XCTAssertEqual(formatter.formatName("jon889 at me.com (Jonathan Bailey)"), "Jonathan Bailey")
        
        // ?utf-8?
        XCTAssertEqual(formatter.formatName("jon889 at me.com (=?utf-8? is Messed)"), "")
    }
    
    func testDateFormatting() {
        // "ccc, dd MMM yyyy HH:mm:ss Z"
        let formatter = EmailFormatter()
        
        let dateComponents = NSDateComponents()
        dateComponents.day = 25
        dateComponents.month = 1
        dateComponents.year = 2016
        dateComponents.hour = 15
        dateComponents.minute = 54
        dateComponents.second = 37
        dateComponents.timeZone = NSTimeZone(abbreviation: "GMT")
        
        let dateFromComponents: NSDate = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.dateFromComponents(dateComponents)!
        let dateAsString = "Mon, 25 Jan 2016 15:54:37 +0000"
        
        XCTAssertEqual(formatter.dateStringToDate(dateAsString), dateFromComponents)
        
        let localDate = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d MMM"
        
        XCTAssertEqual(formatter.formatDate(localDate), dateFormatter.stringFromDate(localDate))
    }
    
    func testFormatContent() {
        let formatter = EmailFormatter()
        let content = "This is some text_______________________________________________Past\nthe\nseparator"
        XCTAssertEqual(formatter.formatContent(content), "This is some text")
        
        let content2 = "This is some text_______________________________________________Past\nthe\nseparator_______________________________________________With\nmultiple\nseparators"
        XCTAssertEqual(formatter.formatContent(content2), "This is some text")
    }
    
    func testGetLabelsInSubject() {
        let subject = "[swift-evolution][Proposal][Accepted] SE-0043 Writing square brackets [like] this"
        let formatter = EmailFormatter()
        let expected = ["swift-evolution", "Proposal", "Accepted", "SE-0043"]
        let actual = formatter.labelsInSubject(subject)
        XCTAssertEqual(expected, actual)
        
        XCTAssertEqual(formatter.labelsInSubject("[swift-evolution] [Request] Variadic parameters as arguments in closures"), ["swift-evolution", "Request"])
    }
    
    func testRemoveLabels() {
        let subject = "[swift-evolution][Proposal][Accepted] JRA-1004 Writing square brackets [like] this"
        let formatter = EmailFormatter()
        let expected = "Writing square brackets [like] this"
        let actual = formatter.subjectByRemovingLabels(subject)
        XCTAssertEqual(expected, actual)
    }
}
