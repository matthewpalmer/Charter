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
    
    /// This method makes a request to the network to retrieve emails. It should only be used if the set of emails returned by `getCachedThreads` is not satisfactory; otherwise, default to `getCachedThreads`.
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
        networkDataSource.getThreads(request) { networkThreads in
            dispatch_async(dispatch_get_main_queue()) {
                let _ = try? self.cacheDataSource.cacheEmails(networkThreads)
                
                self.cacheDataSource.getThreads(request) {
                    completion($0)
                }
            }
        }
    }
}
