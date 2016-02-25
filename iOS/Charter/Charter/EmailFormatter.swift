//
//  EmailFormatter.swift
//  Charter
//
//  Created by Matthew Palmer on 25/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class EmailFormatter {
    private lazy var squareBracketRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^\\[.*\\]", options: .CaseInsensitive)
    }()
    
    private lazy var leadingSpaceRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^\\s+", options: .CaseInsensitive)
    }()
    
    private lazy var withinParenthesesRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "\\((.*)\\)", options: .CaseInsensitive)
    }()
    
    private lazy var sourceDateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "ccc, dd MMM yyyy HH:mm:ss Z"
        return df
    }()
    
    private lazy var destinationDateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "d MMM"
        return df
    }()
    
    private lazy var leadingPunctuationRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^\\W+", options: .CaseInsensitive)
    }()
    
    func formatSubject(subject: String) -> String {
        let noSquareBrackets = squareBracketRegex.stringByReplacingMatchesInString(subject, options: [], range: NSMakeRange(0, subject.characters.count), withTemplate: "")
        let noLeadingPunctuation = leadingPunctuationRegex.stringByReplacingMatchesInString(noSquareBrackets, options: [], range: NSMakeRange(0, noSquareBrackets.characters.count), withTemplate: "")
        let noLeadingSpaces = leadingSpaceRegex.stringByReplacingMatchesInString(noLeadingPunctuation, options: [], range: NSMakeRange(0, noLeadingPunctuation.characters.count), withTemplate: "")
        return noLeadingSpaces
    }
    
    func formatName(name: String) -> String {
        let firstMatch = withinParenthesesRegex.firstMatchInString(name, options: [], range: NSMakeRange(0, name.characters.count))
        let range = firstMatch?.rangeAtIndex(1) ?? NSMakeRange(0, name.characters.count)
        let withinParens = (name as NSString).substringWithRange(range)
        
        // The server sometimes sends us ?utf-8? junk, and there's nothing we can do.
        let noJunk: String
        if withinParens.hasPrefix("=?utf-8?") {
            noJunk = ""
        } else {
            noJunk = withinParens
        }
        
        return noJunk
    }
    
    func dateStringToDate(date: String) -> NSDate? {
        return sourceDateFormatter.dateFromString(date)
    }
    
    func formatDate(date: NSDate) -> String {
        return destinationDateFormatter.stringFromDate(date)
    }
}