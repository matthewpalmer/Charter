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

protocol EmailThread: class {
    var messageID: String { get }
    var from: String { get }
    var date: NSDate { get }
    var subject: String { get }
    var replies: [EmailThread] { get }
    var mailingList: String { get }
}

// Ad-hoc equality because I can't work out how to have self-referential protocols conform to equality (Self or associated type requirements issue).
func ==<T: EmailThread>(lhs: T, rhs: T) -> Bool {
    return lhs.messageID == rhs.messageID
}

class Email: Object, EmailThread {
    dynamic var messageID: String = ""
    dynamic var from: String = ""
    dynamic var date: NSDate = NSDate(timeIntervalSince1970: 1)
    dynamic var subject: String = ""
    dynamic var inReplyTo: Email?
    let references: List<Email> = List<Email>()
    let children: List<Email> = List<Email>()
    dynamic var mailingList: String = ""
    dynamic var content: String = ""
    
    var replies: [EmailThread] {
        return Array(children)
    }
    
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
