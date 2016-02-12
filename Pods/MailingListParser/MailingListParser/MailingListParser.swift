//
//  MailingListParser.swift
//  MailingListParser
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

/// Splits up a collection of emails in a mailing list
public class MailingListParser: NSObject {
    private let string: String
    
    public init(string: String) {
        self.string = string
    }
    
    public lazy var emails: [String] = {
        // TODO: Some emails don't have the extra newline... might be a problem
        let lines: [NSString] = (self.string as NSString).componentsSeparatedByString("\n")
        
        var beginningIndexOfEmails: [Int] = []
        
        var j: Int
        
        for i in 0..<lines.count {
            let line = lines[i]
            // We've definitely hit a new message. Now go back to the previous line that was empty.
            if line.hasPrefix("Message-ID:") {
                j = i
                while j > 0 && lines[j].stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()) != "" {
                    j--
                }
                
                // j is now at the beginning of an email
                beginningIndexOfEmails.append(j)
            }
        }
        
        // beginningIndexOfEmails now partitions `lines` into emails.
        var emails: [String] = []
        
        for i in 0..<beginningIndexOfEmails.count {
            let beginningIndex = beginningIndexOfEmails[i]
            
            let endIndex: Int
            if i == beginningIndexOfEmails.count - 1 {
                endIndex = lines.count - 1
            } else {
                endIndex = beginningIndexOfEmails[i + 1]
            }
            
            let slice = lines[beginningIndex..<endIndex].map { $0 as String }
            let fullEmail = Array<String>(slice).joinWithSeparator("\n")
            let trimmedEmail = (fullEmail as NSString)
                .componentsSeparatedByString("-------------- next part --------------").first ?? ""
            
            emails.append(trimmedEmail.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        }
        
        return emails
    }()
}
