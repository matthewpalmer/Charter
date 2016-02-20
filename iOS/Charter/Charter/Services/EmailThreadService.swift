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
    
    // TOOD: Paging and shit
    
    func getCachedThreads(request: EmailThreadRequest, completion: [Email] -> Void) {
        cacheDataSource.getThreads(request) {
            completion($0)
        }
    }
    
    func getUncachedThreads(request: EmailThreadRequest, completion: [Email] -> Void) {
        networkDataSource.getThreads(request) { [unowned self] networkThreads in
            self.cacheDataSource.cacheThreads(networkThreads) {
                self.cacheDataSource.getThreads(request) {
                    completion($0)
                }
            }
        }
    }
}
