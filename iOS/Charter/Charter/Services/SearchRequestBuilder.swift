//
//  SearchRequestBuilder.swift
//  Charter
//
//  Created by Matthew Palmer on 16/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

/// Construct a search request with text properties. Note: the Realm query provided by the request built by this class should  *not* be used.
class SearchRequestBuilder: NSObject {
    var text: String?
    
    private lazy var params: Dictionary<String, String> = {
        // /charter/emails?filter={$text: {$search: 'Erica'}}&pagesize=50&sort_by={$meta: "textScore"}
        
        let text = self.text ?? ""
        let filter = "{$text:{$search:'\(text)'}}"
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
    
    func build() -> EmailThreadRequest {
        return SearchRequest(URLRequestQueryParameters: params)
    }
}

private struct SearchRequest: EmailThreadRequest {
    let URLRequestQueryParameters: Dictionary<String, String>
    
    var realmQuery: RealmQuery {
        fatalError("\(__LINE__): SearchRequestBuilder does not construct a Realm query.")
    }
}
