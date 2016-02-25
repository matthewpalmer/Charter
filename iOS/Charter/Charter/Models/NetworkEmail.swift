//
//  NetworkEmail.swift
//  Charter
//
//  Created by Matthew Palmer on 25/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import Freddy

struct NetworkEmail {
    let id: String
    let from: String
    let mailingList: String
    let content: String
    let archiveURL: String?
    let date: NSDate
    let subject: String
    let inReplyTo: String?
    let references: [String]
    let descendants: [String]
}

extension NetworkEmail {
    static func createFromJSONData(jsonData: NSData) throws -> NetworkEmail {
        let json = try JSON(data: jsonData)
        return try NetworkEmail.createFromJSON(json)
    }
    
    static func createFromJSON(json: JSON) throws -> NetworkEmail {
        let id = try json.string("_id")
        let from = try json.string("from")
        let interval = try json.int("date", "$date")
        let date = NSDate(timeIntervalSince1970: Double(interval / 1000)) // JSON response is in milliseconds
        let subject = try json.string("subject")
        let mailingList = try json.string("mailingList")
        let content = try json.string("content")
        let archiveURL = try json.string("archiveURL")
        
        let descendants = (try? json.array("descendants").map(String.init).filter { !$0.isEmpty }) ?? []
        let references = (try? json.array("references").map(String.init).filter { !$0.isEmpty }) ?? []
        let inReplyTo = (try? json.string("inReplyTo", ifNull: true)) ?? nil
        
        return NetworkEmail(id: id, from: from, mailingList: mailingList, content: content, archiveURL: archiveURL, date: date, subject: subject, inReplyTo: inReplyTo, references: references, descendants: descendants)
    }
}
