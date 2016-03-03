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
    
    var idIn: [String]? = nil
    
    func build() -> EmailThreadRequest {
        let request = EmailThreadRequestImpl(page: page, pageSize: pageSize, mailingList: mailingList, inReplyTo: inReplyTo, sort: sort, onlyComplete: onlyComplete, idIn: idIn)
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
    
    var idIn: [String]?
    
    var URLRequestQueryParameters: Dictionary<String, String> {
        var dictionary = Dictionary<String, String>()
        
        var filter: Dictionary<String, Either<String, NSNull>> = Dictionary<String, Either<String, NSNull>>()
        if let inReplyTo = inReplyTo {
            filter["inReplyTo"] = inReplyTo
        }
        
        if let mailingList = mailingList {
            filter["mailingList"] = Either.Left(mailingList)
        }
        
        // Members of this list are special queries whose filter values do not want single quotes around them
        let quoteWhiteList = ["{$in"]
        
        if let idIn = idIn {
            // {_id:{ $in:['id_one','id_two',...]}}

            let inQuery = "{$in:[" + idIn.map {
                // NSURLComponents won't escape '+' for us
                let escaped = $0.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet(charactersInString: "+").invertedSet) ?? ""
                return "'\(escaped)'"
            }.joinWithSeparator(",") + "]}"
            
            filter["_id"] = Either.Left(inQuery)
        }
        
        let filterArgs = filter.sort { $0.0 < $1.0 }.map { (pair: (String, Either<String, NSNull>)) -> String in
            let key = pair.0
            let either = pair.1
            
            let valueString: String
            switch either {
            case .Left(let value):
                let isOnWhiteList = quoteWhiteList.map { value.hasPrefix($0) }.filter { $0 == true }.count > 0
                if isOnWhiteList {
                    valueString = "\(value)"
                } else {
                    valueString = "'\(value)'"
                }
            case .Right:
                valueString = "null"
            }
            return "\(key):\(valueString)"
        }
        
        let filterValueString = jsonFromEntryStrings(filterArgs)
        
        dictionary["filter"] = filterValueString
        
        if let sort = sort where sort.count > 0 {
            dictionary["sort_by"] = "\(sort.first!.1 ? "" : "-")\(sort.first!.0)"
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
        var predicateComponents: [String] = []
        
        if let inReplyTo = inReplyTo {
            let filterValueString: String
            switch inReplyTo {
            case .Left(let value):
                filterValueString = "'\(value)'"
            case .Right:
                filterValueString = "nil"
            }
            
            predicateComponents.append("inReplyTo == \(filterValueString)")
        }
        
        if let mailingList = mailingList {
            predicateComponents.append("mailingList == '\(mailingList)'")
        }
        
        if let idIn = idIn {
            let component = "id IN {" + idIn.map { "'\($0)'" }.joinWithSeparator(",") + "}"
            predicateComponents.append(component)
        }
        
        let predicate = NSPredicate(format: predicateComponents.joinWithSeparator(" AND "))
        
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

