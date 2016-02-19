//
//  EmailThreadRequest.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

protocol NetworkingSession {
    
}

extension NSURLSession: NetworkingSession {
    
}

class Request: EmailThreadNetworkDataSource {
    private let session: NetworkingSession
    
    init(username: String = , password: String, session: NetworkingSession = NSURLSession.sharedSession()) {
        self.session = session
    }
    
    func getThreads(completion: [EmailThread] -> Void) {
        
    }
}
