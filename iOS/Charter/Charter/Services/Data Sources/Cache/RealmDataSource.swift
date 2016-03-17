//
//  RealmCacheDataSource.swift
//  Charter
//
//  Created by Matthew Palmer on 25/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDataSource: EmailThreadCacheDataSource {
    private let realm: Realm
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }
    
    func getThreads(request: CachedThreadRequest, completion: [Email] -> Void) {
        let realmQuery = request.realmQuery
        var results = realm.objects(Email).filter(realmQuery.predicate)
        
        if realmQuery.onlyComplete {
            results = results.filter("subject != '' AND from != '' AND mailingList != ''")
        }
        
        if let sort = realmQuery.sort {
            results = results.sorted(sort.property, ascending: sort.ascending)
        }
        
        let start = realmQuery.pageSize * (realmQuery.page - 1)
        
        var end = start + realmQuery.pageSize
        if end > results.count {
            end = results.count
        }
        
        if results.count == 0 {
            completion([])
        } else {
            let slice = results[start..<end]
            completion(Array(slice))
        }
    }
    
    func cacheEmails(emails: [NetworkEmail]) throws {
        try emails.forEach { email in
            try Email.createFromNetworkEmail(email, inRealm: realm)
        }
    }
}
