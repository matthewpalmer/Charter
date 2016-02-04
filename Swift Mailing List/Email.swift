//
//  Email.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 4/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import MailingListParser

struct Email {
    let headers: MailingListMessageHeaders
    let content: String
    let mailingList: MailingList
}

extension Email: Equatable {}

func ==(lhs: Email, rhs: Email) -> Bool {
    return lhs.headers == rhs.headers && lhs.content == rhs.content && lhs.mailingList == rhs.mailingList
}

extension Email: Hashable {
    var hashValue: Int { return headers.messageID.hashValue }
}
