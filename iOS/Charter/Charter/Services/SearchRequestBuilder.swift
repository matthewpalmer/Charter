//
//  SearchRequestBuilder.swift
//  Charter
//
//  Created by Matthew Palmer on 16/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

/// Construct a search request with text properties. Note: the Realm query provided by the request built by this class should  **not** be used, i.e. don't try to use this request to retrieve cached results.
class SearchRequestBuilder: NSObject {
    var text: String?
    var mailingList: String?
    
    private lazy var params: Dictionary<String, String> = {
        // /charter/emails?filter={$text: {$search: 'Erica'}}&pagesize=50&sort_by={$meta: "textScore"}
        
        let text = self.text ?? ""
        
        var mailingListField: String?
        if self.mailingList != nil {
            mailingListField = "mailingList:'\(self.mailingList!)'"
        }
        
        var filter = "{$text:{$search:'\(text)'}\(mailingListField != nil ? ",\(mailingListField!)" : "")}"
        
        let params: [String: String] = [
            "filter": filter,
            "pagesize": "50",
            "sort_by": "{$meta:'textScore'}"
        ]
        return params
    }()
    
    private lazy var realmQuery: RealmQuery = {
        return RealmQuery(predicate: NSPredicate(format: ""), sort: nil, page: 1, pageSize: 0, onlyComplete: true)
    }()
    
    func build() -> UncachedThreadRequest {
        return SearchRequest(URLRequestQueryParameters: params)
    }
}

private struct SearchRequest: UncachedThreadRequest {
    let URLRequestQueryParameters: Dictionary<String, String>
}
