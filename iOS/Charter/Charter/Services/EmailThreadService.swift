//
//  ThreadService.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation
import RealmSwift

protocol EmailThreadCacheDataSource: class {
    func getThreads() -> [EmailThread]
    func cacheThreads(threads: [EmailThread], completion: Void -> Void)
}

protocol EmailThreadNetworkDataSource: class {
    func getThreads(completion: [EmailThread] -> Void)
}

protocol EmailThreadService {
    init(cacheDataSource: EmailThreadCacheDataSource, networkDataSource: EmailThreadNetworkDataSource)
    func getCachedThreads(completion: [EmailThread] -> Void)
    func getUncachedThreads(completion: [EmailThread] -> Void)
}

class EmailThreadServiceImpl: EmailThreadService {
    let cacheDataSource: EmailThreadCacheDataSource
    let networkDataSource: EmailThreadNetworkDataSource
    
    required init(cacheDataSource: EmailThreadCacheDataSource, networkDataSource: EmailThreadNetworkDataSource) {
        self.cacheDataSource = cacheDataSource
        self.networkDataSource = networkDataSource
    }
    
    // TOOD: Paging and shit
    
    func getCachedThreads(completion: [EmailThread] -> Void) {
        completion(cacheDataSource.getThreads())
    }
    
    func getUncachedThreads(completion: [EmailThread] -> Void) {
        networkDataSource.getThreads { [unowned self] networkThreads in
            self.cacheDataSource.cacheThreads(networkThreads) {
                completion(self.cacheDataSource.getThreads())
            }
        }
    }
}
