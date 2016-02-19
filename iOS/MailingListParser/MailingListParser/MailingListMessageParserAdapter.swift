//
//  File.swift
//  MailingListParser
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

/// Converts the result of a parsed message to a strongly typed `MailingListMessage`
public class MailingListMessageParserAdapter: NSObject {
    public let messageParser: MailingListMessageParser
    
    public init(mailingListMessageParser: MailingListMessageParser) {
        self.messageParser = mailingListMessageParser
    }
    
    public lazy var mailingListMessageHeaders: MailingListMessageHeaders? = {
        guard let
            from = self.messageParser.from,
            subject = self.messageParser.subject,
            messageID = self.messageParser.messageID,
            date = self.messageParser.date
            else {
                return nil
        }
        
        let messageIDDelimiterSet = NSCharacterSet(charactersInString: "<>")
        
        let referencesString = (self.messageParser.references ?? "")
        let references = self.referencesStringToList(referencesString)
            .map { $0.stringByTrimmingCharactersInSet(messageIDDelimiterSet) }
        let inReplyTo = self.messageParser.inReplyTo?.stringByTrimmingCharactersInSet(messageIDDelimiterSet)
        return MailingListMessageHeaders(from: from, date: date, subject: subject, inReplyTo: inReplyTo, references: references, messageID: messageID.stringByTrimmingCharactersInSet(messageIDDelimiterSet))
    }()
    
    public lazy var mailingListMessage: MailingListMessage? = {
        guard let content = self.messageParser.contentString else { return nil }
        guard let headers = self.mailingListMessageHeaders else { return nil }
        return MailingListMessage(headers: headers, content: content)
    }()
    
    private func referencesStringToList(from: String) -> [String] {
        return (from as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}