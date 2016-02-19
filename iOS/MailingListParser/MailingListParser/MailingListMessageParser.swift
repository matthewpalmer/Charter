//
//  MailingListMessageParser.swift
//  MailingListParser
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

/// Parses a single message in a mailing list format
public  class MailingListMessageParser: NSObject {
    private let string: NSString
    
    public init(string: String) {
        self.string = string as NSString
    }
    
    private lazy var headerRange: NSRange? = {
        // Get the first line beginning with "Message-ID:" up until the end of the line
        let pattern = "^Message-ID:.*$"
        let range = NSMakeRange(0, self.string.length)
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .AnchorsMatchLines) else { return nil }
        let matches = regex.matchesInString(self.string as String, options: NSMatchingOptions.WithoutAnchoringBounds, range: range)
        guard let firstMatch = matches.first?.rangeAtIndex(0) else { return nil }
        return NSMakeRange(0, firstMatch.location + firstMatch.length)
    }()
    
    lazy private var headerString: String? = {
        guard let headerRange = self.headerRange else { return nil }
        return self.string.substringWithRange(headerRange)
    }()

    lazy public private(set) var from: String? = {
        return self.headerFieldStringValue("From")
    }()
    
    lazy public private(set) var date: String? = {
        return self.headerFieldStringValue("Date")
    }()
    
    lazy public private(set) var subject: String? = {
        return self.headerFieldStringValue("Subject")
    }()
    
    lazy public private(set) var inReplyTo: String? = {
        return self.headerFieldStringValue("In-Reply-To")
    }()
    
    lazy public private(set) var messageID: String? = {
        return self.headerFieldStringValue("Message-ID")
    }()
    
    lazy public private(set) var references: String? = {
        return self.headerFieldStringValue("References")
    }()
    
    lazy private var flattenedHeaderString: String? = {
        if self.headerString == nil { return nil }
        let header = NSString(string: self.headerString!)
        
        let lines = header.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        
        // If line begins with one or more spaces then it is part of the previous field
        // e.g.
        // References: <blah@fkdjshal>
        //    <blah2@gh>
        //    <blah3@ghi>
        
        // > Unfolding  is  accomplished  by
        // > regarding   CRLF   immediately  followed  by  a  LWSP-char  as
        // > equivalent to the LWSP-char.
        
        var flattenedLines: [String] = []
        
        for line in lines {
            if line.hasPrefix(" ") || line.hasPrefix("\t") {
                var last = flattenedLines.popLast() ?? ""
                let noTabs = line.stringByReplacingOccurrencesOfString("\t", withString: " ")
                last.appendContentsOf(noTabs)
                flattenedLines.append(last)
            } else {
                flattenedLines.append(line)
            }
        }
        
        return flattenedLines.joinWithSeparator("\r\n")
    }()
    
    private func headerFieldStringValue(field: String) -> String? {
        guard flattenedHeaderString != nil else { return nil }
        let header = flattenedHeaderString! as NSString
        
        let pattern = "^\(field):\\s*(.*?)$"
        let range = NSMakeRange(0, header.length)
 
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.AnchorsMatchLines, .DotMatchesLineSeparators]) else { return nil }
        let matches = regex.matchesInString(header as String, options: NSMatchingOptions.WithoutAnchoringBounds, range: range)
        guard let firstMatch = matches.first?.rangeAtIndex(1) else { return nil }
        return header.substringWithRange(firstMatch)
    }
    
    lazy public private(set) var contentString: String? = {
        guard let headerRange = self.headerRange else { return nil }
        let start = headerRange.location + headerRange.length
        let contentRange = NSMakeRange(start, self.string.length - start)
        let allContent = self.string.substringWithRange(contentRange) as NSString
        let strippedContent = allContent.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        return strippedContent
    }()
}
