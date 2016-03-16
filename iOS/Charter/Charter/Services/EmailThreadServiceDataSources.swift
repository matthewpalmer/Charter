//
//  EmailThreadDataSources.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation
import RealmSwift

protocol EmailThreadCacheDataSource: class {
    func getThreads(request: CachedThreadRequest, completion: [Email] -> Void)
    
    /// Should update values in the realm, with precedence as follows: the email incoming to the cache (i.e. from the network) should replace the existing one. This works because a network email *must* be fully formed, i.e. it must be at least as filled out as the one in the cache.
    func cacheEmails(emails: [NetworkEmail]) throws
}

protocol EmailThreadNetworkDataSource: class {
    func getThreads(request: UncachedThreadRequest, completion: [NetworkEmail] -> Void)
}
