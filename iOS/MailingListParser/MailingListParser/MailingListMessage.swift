//
//  MailingListMessage.swift
//  MailingListParser
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

public struct MailingListMessage {
    public let headers: MailingListMessageHeaders
    public let content: String
}

extension MailingListMessage: Equatable {}
public func ==(lhs: MailingListMessage, rhs: MailingListMessage) -> Bool {
    return lhs.headers == rhs.headers && lhs.content == rhs.content
}

