//
//  MailingListMessageHeaders.swift
//  MailingListParser
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

public struct MailingListMessageHeaders {
    public let from: String
    public let date: String
    public let subject: String
    public let inReplyTo: String?
    public let references: [String]
    public let messageID: String
}

extension MailingListMessageHeaders: Equatable {}
public func ==(lhs: MailingListMessageHeaders, rhs: MailingListMessageHeaders) -> Bool {
    return lhs.from == rhs.from
        && lhs.date == rhs.date
        && lhs.subject == rhs.subject
        && lhs.inReplyTo == rhs.inReplyTo
        && lhs.references == rhs.references
        && lhs.messageID == rhs.messageID
}
