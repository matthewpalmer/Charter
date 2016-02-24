//
//  ThreadService.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

protocol EmailThreadService {
    init(cacheDataSource: EmailThreadCacheDataSource, networkDataSource: EmailThreadNetworkDataSource)
    func getCachedThreads(request: EmailThreadRequest, completion: [Email] -> Void)
    func getUncachedThreads(request: EmailThreadRequest, completion: [Email] -> Void)
}

class EmailThreadServiceImpl: EmailThreadService {
    let cacheDataSource: EmailThreadCacheDataSource
    let networkDataSource: EmailThreadNetworkDataSource
    
    required init(cacheDataSource: EmailThreadCacheDataSource, networkDataSource: EmailThreadNetworkDataSource) {
        self.cacheDataSource = cacheDataSource
        self.networkDataSource = networkDataSource
    }
    
    func getCachedThreads(request: EmailThreadRequest, completion: [Email] -> Void) {
        cacheDataSource.getThreads(request) {
            completion($0)
        }
    }
    
    func getUncachedThreads(request: EmailThreadRequest, completion: [Email] -> Void) {
        // There's an unfortunate side effect to using Realm where I don't think we can create emails without putting them into a realm because of the ways that `descendants`, `references`, and `inReplyTo` work. This means that the network data source has the additional responsibility of putting retrieved objects into the Realm. We can work around this by creating a new network model that a `EmailThreadNetworkDataSource` can return that has references/descendants/inReplyTo as strings rather than Email references, and then we should add a method to the `EmailThreadCacheDataSource` to cache emails that are in this format. Let's make this a todo.
        // TODO: Remove side effects from the network data source
        
        // There are some issues when we make a request for the same emails twice--we need to add upsert-ability. (This is another reason we need to draw out these responsibilities.)
        // TODO: Add upsert for the network data source caching
        
        networkDataSource.getThreads(request) { networkThreads in
            dispatch_async(dispatch_get_main_queue()) {
                self.cacheDataSource.getThreads(request) {
                    completion($0)
                }
            }
        }
    }
}
