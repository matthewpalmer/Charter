//
//  ThreadService.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol EmailThreadService {
    init(cacheDataSource: EmailThreadCacheDataSource, networkDataSource: EmailThreadNetworkDataSource)
    func getCachedThreads(request: CachedThreadRequest, completion: [Email] -> Void)
    func refreshCache(request: EmailThreadRequest, completion: [Email] -> Void)
}

protocol Application {
    var networkActivityIndicatorVisible: Bool { get set }
}

extension UIApplication: Application {}

class EmailThreadServiceImpl: EmailThreadService {
    let cacheDataSource: EmailThreadCacheDataSource
    let networkDataSource: EmailThreadNetworkDataSource
    
    var application: Application = UIApplication.sharedApplication()
    
    required init(cacheDataSource: EmailThreadCacheDataSource, networkDataSource: EmailThreadNetworkDataSource) {
        self.cacheDataSource = cacheDataSource
        self.networkDataSource = networkDataSource
    }
    
    func getCachedThreads(request: CachedThreadRequest, completion: [Email] -> Void) {
        cacheDataSource.getThreads(request) {
            completion($0)
        }
    }
    
    func refreshCache(request: EmailThreadRequest, completion: [Email] -> Void) {
        application.networkActivityIndicatorVisible = true
        
        networkDataSource.getThreads(request) { networkThreads in
            dispatch_async(dispatch_get_main_queue()) {
                self.application.networkActivityIndicatorVisible = false
                
                let _ = try? self.cacheDataSource.cacheEmails(networkThreads)
                
                self.cacheDataSource.getThreads(request) {
                    completion($0)
                }
            }
        }
    }
}
