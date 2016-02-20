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
    func getThreads(request: EmailThreadRequest, completion: [Email] -> Void)
    func cacheThreads(threads: [Email], completion: Void -> Void)
}

protocol EmailThreadNetworkDataSource: class {
    func getThreads(request: EmailThreadRequest, completion: [Email] -> Void)
}
