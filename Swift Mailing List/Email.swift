//
//  Email.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 4/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import MailingListParser
import RealmSwift

class Email: Object {
    dynamic var messageID: String = ""
    dynamic var from: String = ""
    dynamic var date: NSDate = NSDate(timeIntervalSince1970: 1)
    dynamic var subject: String = ""
    dynamic var inReplyTo: Email?
    let references: List<Email> = List<Email>()
    dynamic var mailingList: String = ""
    dynamic var content: String = ""
    
    override static func primaryKey() -> String? {
        return "messageID"
    }
}

extension Email: Equatable {}

func ==(lhs: Email, rhs: Email) -> Bool {
    return lhs.messageID == rhs.messageID
}

extension Email: Hashable {
    override var hashValue: Int { return messageID.hashValue }
}
