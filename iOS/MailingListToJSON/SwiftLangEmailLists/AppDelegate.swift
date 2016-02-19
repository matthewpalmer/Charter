//
//  AppDelegate.swift
//  SwiftLangEmailLists
//
//  Created by Matthew Palmer on 11/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Cocoa
import MailingListParser

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        SwiftEvolution()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

func SwiftEvolution() {
    print("Running Swift evolution...\n\n")
    
    let filePaths: [String] = [
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20151130.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20151207.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20151214.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20151221.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20151228.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20160104.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20160111.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20160118.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20160125.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20160201.txt",
        "/Users/matthewpalmer/Desktop/swift-evolution/Week-of-Mon-20160208.txt",
    ]
    
    let anchors: [String: Int] = [
        "2E514F6E-5BF9-465D-AC41-D1182E0FA373@apple.com": 411,
        "52258245-20CC-4C12-864C-31A8EA887E5E@gmail.com": 714,
        "CAOAJ4FnYh7m6edY0JYsNnKVeoXzRk-W4qDAWCMVB3oQ8k6ANCg@mail.gmail.com": 786,
        "21737FB0-EC7A-44DC-BC89-862AEAA29513@me.com": 1452,
        "C19ADC7D-BFD4-44AA-A768-3A7CC50EAFE2@apple.com": 1625,
        "CAJvk5nUoVirUgaBOffMP=F_Ynt0kO4TwHHJp7HpeHj6ygduXtw@mail.gmail.com": 1945,
        "64580F46-163F-4ED6-9E22-BF51C8214A1A@apple.com": 2191,
        "314948C9-8995-4F5F-A0C1-660AACD1BAE9@gmail.com": 2942,
        "4BDA06CE-68EC-414B-B907-607D1F0D7E3F@gmx.de": 3720,
        "E2050800-1650-4B5F-9A00-9A607D57C9CF@owensd.io": 3815,
        "ANFz0qtKuuaVpUJB6Ly=GVAg0WQGmo3NhvzunvyqnXDPbL-XBA@mail.gmail.com": 4144,
        "1FDA4FD2-2D69-4B31-8479-401581A7D067@iki.fi": 4569,
        "1451282770.3016032.477471210.05EDECC9@webmail.messagingengine.com": 4626,
        "B9DC7A4C-C442-4FAA-B387-45918B043A50@alkaline-solutions.com": 4823,
        "0686D5B9-A07A-4FAB-8976-6F1B68F1C3AC@catrondevelopment.com": 5220,
        "C9B8D0FD-12A5-44C7-ACDF-A24FD7EF9A4F@architechies.com": 6003,
        "3AF38FC4-95BE-45F2-844D-7DD1C4ED1532@sb.org": 6193,
        "CAB5C60tafuPaBdAhqVeQ5P0PsAQegKtrQPBnH+Ah1T-GzFsdxw@mail.gmail.com": 6855,
        "21E465A5-F071-4D35-A459-8E1DD7729106@apple.com": 6904,
        "960C20B3-BC70-43DF-9E86-46A4B915315F@gmail.com": 7641,
        "C6886EB9-C192-428B-B843-EDE9D474F201@gmail.com": 8608,
        "8951F93C-E3FA-49FB-BEE1-C27C6B44F2F4@me.com": 9363,
        "85E94948-9B8F-40CF-9D63-AB442C85B2BA@novafore.com": 9566,
    ]
    
    let evolution = ParseList("swift-evolution", filePaths: filePaths, messageNumberAnchors: anchors).stringByReplacingOccurrencesOfString("\n", withString: "")
    
    try! evolution.writeToFile("/Users/matthewpalmer/Desktop/swift-evolution/evolution.json", atomically: true, encoding: NSUTF8StringEncoding)
    
    print("\n\n===========\n\nFinished running Swift evolution")
}

// File paths last path component must be of format Week-of-Mon-20160208.txt and in ascending order
// message number anchors anchor a particular message ID to a message number to help reduce errors.
func ParseList(listId: String, filePaths: [String], messageNumberAnchors: [String: Int]) -> String {
    var finalJSON = "["
    
    var messageNumber = 411 // starting message number
    
    for file in filePaths {
        let data = NSData(contentsOfFile: file)!
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let parser = MailingListParser(string: string as String)
        let emails = parser.emails
        
        let period = NSURL(string: file)!.lastPathComponent!.stringByReplacingOccurrencesOfString(".txt", withString: "")
        
        for email in emails {
            let messageParser = MailingListMessageParser(string: email)
            let adapter = MailingListMessageParserAdapter(mailingListMessageParser: messageParser)
            let message = adapter.mailingListMessage
            
            if message == nil {
                print("Failed to parse email:\n\n\(email)\n\nSkipping this email\nmessage number: \(messageNumber)")
                messageNumber++
                continue
            }
            
            if let anchor = messageNumberAnchors[message!.headers.messageID] {
                messageNumber = anchor
            }
            
            let json = messageToJSONString(listId, period: period, messageNumber: messageNumber, message: message!)
            
            if email == emails.last && file == filePaths.last {
                finalJSON += json
            } else {
                finalJSON += json + ","
            }
            
            messageNumber++
            
        }
    }
    
    finalJSON += "]"
    return finalJSON
}

func messageToJSONString(mailingList: String, period: String, messageNumber: Int, message: MailingListMessage) -> String {
    // NSString *example = [NSString stringWithFormat:@"%010d", number];
    
    // https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20151130/000411.html
    let paddedNumber = NSString(format: "%06d", messageNumber)
    let archiveURL = "https://lists.swift.org/pipermail/\(mailingList)/\(period)/\(paddedNumber).html"
    
    let dictionary: NSMutableDictionary = [
        "_id": message.headers.messageID,
        "from": message.headers.from,
        "date": message.headers.date,
        "subject": message.headers.subject,
        "references": message.headers.references,
        "mailingList": mailingList,
        "content": message.content,
        "archiveURL": archiveURL
    ]
    
    if let inReplyTo = message.headers.inReplyTo {
        dictionary["inReplyTo"] = inReplyTo
    }
    
    let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
    return String(data: data, encoding: NSUTF8StringEncoding)!
}

