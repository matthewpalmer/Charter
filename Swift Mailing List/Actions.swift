//
//  Actions.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation
import ReSwift
import MailingListParser

struct NextRouteAcknowledged: Action {}

struct MoveTo: Action {
    let route: Route
}

struct SetEmailList: Action {
    let contents: [Email]
}

struct ListPeriod {
    let identifier: String
    
    var fileName: String { return identifier }
}

func RequestSwiftEvolution(period: ListPeriod, useCache: Bool = true) -> ((_: AppState, _: Store<AppState>) -> Action?) {
    return { _, _ in
        func filePathForPeriod(period: ListPeriod) -> String? {
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            guard let documentsDirectory = paths.first else { return nil }
            let file = (documentsDirectory as NSString).stringByAppendingPathComponent(period.fileName)
            return file
        }
        
        func dispatchActionForUncompressedData(data: NSData) {
            guard let listString = NSString(data: data, encoding: NSUTF8StringEncoding) else { return }
            let emails = MailingListParser(string: listString as String)
                .emails
                .map { return MailingListMessageParser(string: $0) }
                .map { return MailingListMessageParserAdapter(mailingListMessageParser: $0) }
                .map { $0.mailingListMessage }
                .filter { $0 != nil }
                .map { $0! }
            
            mainStore.dispatch(SetEmailList(contents: emails))
        }
        
        func doNetworkRequest() -> Action? {
            let session = NSURLSession(configuration: .defaultSessionConfiguration())
            let URL = NSURL(string: "https://lists.swift.org/pipermail/swift-evolution/\(period.identifier).txt.gz")!
            let request = NSURLRequest(URL: URL)
            
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                if let compressedData = data,
                    uncompressedData = compressedData.gunzippedData(),
                    file = filePathForPeriod(period) {
                        uncompressedData.writeToFile(file, atomically: true)
                        
                        dispatchActionForUncompressedData(uncompressedData)
                }
            }
            
            task.resume()
            return nil
        }
        
        if useCache {
            // Load from local file, otherwise get the result from the network.
            guard let file = filePathForPeriod(period), data = NSData(contentsOfFile: file) else {
                return doNetworkRequest()
            }
            
            dispatchActionForUncompressedData(data)
            return nil
        }
        
        return doNetworkRequest()
    }
}
