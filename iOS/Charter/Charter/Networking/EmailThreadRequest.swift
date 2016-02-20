//
//  EmailThreadRequest.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation

protocol NetworkingSession {
    func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask
}

extension NSURLSession: NetworkingSession {}

// http://162.243.241.218:8080/charter/emails?filter={inReplyTo: null}&sort={date: -1}&pagesize=25&page=1

class ThreadRequest {
    
}


class EmailThreadRequest: EmailThreadNetworkDataSource {
    private let session: NetworkingSession
    private let username: String
    private let password: String
    
    required init(username: String? = nil, password: String? = nil, session: NetworkingSession = NSURLSession.sharedSession()) {
        self.session = session
        
        if let username = username, password = password {
            self.username = username
            self.password = password
        } else if username == nil || password == nil {
            let dictionary = NSDictionary(contentsOfURL: NSBundle.mainBundle().URLForResource("Credentials", withExtension: "plist")!)
            self.username = dictionary!["username"] as! String
            self.password = dictionary!["password"] as! String
        } else {
            fatalError("\(__FILE__): Username and password must be provided to a request. Ensure that a Credentials.plist file exists with `username` and `password` set.")
        }
    }
    
    func getThreads(completion: [Email] -> Void) {
        let components = NSURLComponents(string: "http://162.243.241.218:8080/charter/emails")!
        
        // TODO: This is reusable
        let pageSize = NSURLQueryItem(name: "pagesize", value: "25")
        let page = NSURLQueryItem(name: "page", value: "1")
        let filter = NSURLQueryItem(name: "filter", value: "{inReplyTo: null}")
        
        components.queryItems?.appendContentsOf([pageSize, page, filter])
        
        let URL = components.URL!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: URL)

        // TODO: This is reusable
        let base64 = "\(username):\(password)"
            .dataUsingEncoding(NSUTF8StringEncoding)?
            .base64EncodedStringWithOptions([])
        
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard let data = data else { return completion([]) }
            
            do {
//                let thread = try Email(jsonData: data)
                
            } catch let e {
                print(e)
                completion([])
            }
        }
        
        task.resume()
    }
}
