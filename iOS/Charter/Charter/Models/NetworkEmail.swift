//
//  NetworkEmail.swift
//  Charter
//
//  Created by Matthew Palmer on 25/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

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

enum NetworkEmailError: ErrorType {
    case MissingRequiredField
    case InvalidDate
    case InvalidJSON
}

extension NetworkEmail {
    init(fromDictionary: NSDictionary) throws {
        let d = fromDictionary
        
        guard let
            id = d["_id"] as? String,
            from = d["from"] as? String,
            mailingList = d["mailingList"] as? String,
            content = d["content"] as? String,
            subject = d["subject"] as? String
            else {
                throw NetworkEmailError.MissingRequiredField
        }
        
        let references = ((d["references"] as? [String]) ?? []).filter { !$0.isEmpty }
        let descendants = ((d["descendants"] as? [String]) ?? []).filter { !$0.isEmpty }
        let inReplyTo = d["inReplyTo"] as? String
        let archiveURL = d["archiveURL"] as? String
        
        guard let dateDict = d["date"] as? NSDictionary, interval = dateDict["$date"] as? Double else {
            throw NetworkEmailError.InvalidDate
        }
        let date = NSDate(timeIntervalSince1970: interval / 1000)
        
        self.init(id: id, from: from, mailingList: mailingList, content: content, archiveURL: archiveURL, date: date, subject: subject, inReplyTo: inReplyTo, references: references, descendants: descendants)
    }
    
    static func listFromJSONData(data: NSData) throws -> [NetworkEmail] {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        
        guard let dictionary = json as? NSDictionary,
            embedded = dictionary["_embedded"] as? NSDictionary,
            docs = embedded["rh:doc"] as? Array<NSDictionary> else { throw NetworkEmailError.InvalidJSON }
        
        return docs.map { try? NetworkEmail(fromDictionary: $0) }.flatMap { $0 }
    }
}
