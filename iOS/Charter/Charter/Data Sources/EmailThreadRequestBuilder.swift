//
//  File.swift
//  Charter
//
//  Created by Matthew Palmer on 21/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

class EmailThreadRequestBuilder {
    var page: Int?
    var pageSize: Int?
    
    var mailingList: String?
    var inReplyTo: Either<String, NSNull>?
    
    /// (fieldName, sortAscending)
    var sort: [(String, Bool)]?
    
    /// Only fully-formed documents should be returned
    var onlyComplete = false
    
    func build() -> EmailThreadRequest {
        let request = EmailThreadRequestImpl(page: page, pageSize: pageSize, mailingList: mailingList, inReplyTo: inReplyTo, sort: sort, onlyComplete: onlyComplete)
        if sort?.count > 1 {
            print("WARNING: EmailThreadRequest does not yet have support for multiple sort parameters.")
        }
        return request
    }
}

private struct EmailThreadRequestImpl: EmailThreadRequest {
    var page: Int?
    var pageSize: Int?
    
    var mailingList: String?
    var inReplyTo: Either<String, NSNull>?
    
    /// (fieldName, sortAscending)
    var sort: [(String, Bool)]?
    
    var onlyComplete: Bool
    
    var URLRequestQueryParameters: Dictionary<String, String> {
        var dictionary = Dictionary<String, String>()
        
        var filter: Dictionary<String, Either<String, NSNull>> = Dictionary<String, Either<String, NSNull>>()
        if let inReplyTo = inReplyTo {
            filter["inReplyTo"] = inReplyTo
        }
        
        let filterArgs = filter.map { (pair: (String, Either<String, NSNull>)) -> String in
            let key = pair.0
            let either = pair.1
            
            let valueString: String
            switch either {
            case .Left:
                valueString = "'\(either)'"
            case .Right:
                valueString = "null"
            }
            return "\(key): \(valueString)"
        }
        
        let filterValueString = jsonFromEntryStrings(filterArgs)
        
        dictionary["filter"] = filterValueString
        
        let sortArgs = sort?.map { "\($0.0): \($0.1 ? 1 : -1)" } ?? []
        if let _ = sort {
            dictionary["sort"] = jsonFromEntryStrings(sortArgs)
        }
        
        if let pageSize = pageSize {
            dictionary["pagesize"] = "\(pageSize)"
        }
        
        if let page = page {
            dictionary["page"] = "\(page)"
        }
        
        return dictionary
    }
    
    var realmQuery: RealmQuery {
        var filterValueString: String?
        if let inReplyTo = inReplyTo {
            switch inReplyTo {
            case .Left:
                filterValueString = "'\(inReplyTo)'"
            case .Right:
                filterValueString = "nil"
            }
        }

        let predicate: NSPredicate
        if let filterValueString = filterValueString {
            predicate = NSPredicate(format: "inReplyTo == \(filterValueString)")
        } else {
            predicate = NSPredicate()
        }
        
        let query = RealmQuery(predicate: predicate, sort: self.sort?.first, page: page ?? 1, pageSize: pageSize ?? 25, onlyComplete: onlyComplete)
        return query
    }
}

private func jsonFromEntryStrings(entries: [String]) -> String {
    var str = "{"
    for entry in entries {
        if entry == entries.last {
            str += entry
        } else {
            str += entry + ","
        }
    }
    str += "}"
    return str
}

