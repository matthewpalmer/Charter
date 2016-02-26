//
//  EmailThreadRequest.swift
//  Charter
//
//  Created by Matthew Palmer on 21/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

struct RealmQuery {
    let predicate: NSPredicate
    let sort: (property: String, ascending: Bool)?
    let page: Int
    let pageSize: Int
    let onlyComplete: Bool
}

protocol EmailThreadRequest {
    var URLRequestQueryParameters: Dictionary<String, String> { get }
    var realmQuery: RealmQuery { get }
}
