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
import RealmSwift

struct NextRouteAcknowledged: Action {}

struct MoveTo: Action {
    let route: Route
}

struct SetEmailList: Action {
    let results: Results<Email>?
}

struct SetEmailThread: Action {
    let thread: [(Int, Email)]?
}

struct SetSelectedMailingList: Action {
    let list: MailingList?
}

struct SetSelectedThreadWithRootMessageID: Action {
    let rootMessageID: String?
}

struct ListPeriod {
    let identifier: String
    
    var fileName: String { return identifier }
}

struct SetMailingListIsRefreshing: Action {
    let mailingList: MailingList
    let isRefreshing: Bool
}

func ComputeAndSetThreadForEmail(email: Email) -> ((_: AppState, _: Store<AppState>) -> Action?) {
    return { _, _ in
        func blah(root: Email, indentLevel: Int) -> [(Int, Email)] {
            var list = [(Int, Email)]()
            for child in root.children {
                list.appendContentsOf(blah(child, indentLevel: indentLevel + 1))
            }
            return [(indentLevel, root)] + list
        }
        
        let thread = blah(email, indentLevel: 0)
        return SetEmailThread(thread: thread)
    }
}

func RetrieveRootEmails(list: MailingList) -> ((_: AppState, _: Store<AppState>) -> Action?) {
    return { _, _ in
        let realm = try! Realm()
        
        let query = "mailingList = '\(list.rawValue.identifier)' AND inReplyTo = nil"
        let sortedEmails = realm.objects(Email).filter(query).sorted("date", ascending: false)
        
        return SetEmailList(results: sortedEmails)
    }
}

/// This function computes the most recent archival list period for a given date.
///
/// An example can be found here: the [swift-users](https://lists.swift.org/pipermail/swift-users/) mailing list archive page.
///
/// This function **only handles weekly lists**, so for example swift-evolution-announce (a list archived monthly) cannot be used with this function.
///
/// Prior to the week following the 30th of November 2015 (i.e. the first week of December) there were no archival lists. This function does not check whether your date is valid, it only formats the date into the desired ListPeriod.
func MostRecentListPeriodForDate(date: NSDate = NSDate()) -> ListPeriod {
    // The list archives are referenced by the week beginning on Monday.
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    calendar.locale = NSLocale(localeIdentifier: "en-US")
    
    // If today is a Monday, compute for today. Otherwise, compute for the previous monday.
    let monday: NSDate
    
    let mondayWeekday = 2
    
    if calendar.components(.Weekday, fromDate: date).weekday == mondayWeekday {
        monday = date
    } else {
        monday = calendar.nextDateAfterDate(date, matchingUnit: NSCalendarUnit.Weekday, value: mondayWeekday, options: [.SearchBackwards, .MatchStrictly])!
    }
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yMMdd"
    let dateString = dateFormatter.stringFromDate(monday)
    
    let str = "Week-of-Mon-\(dateString)"
    return ListPeriod(identifier: str)
}

func DownloadData(period: ListPeriod, mailingList: MailingList) -> ((_: AppState, _: Store<AppState>) -> Action?) {
    return { _, store in
        func dispatchActionForUncompressedData(data: NSData) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard let listString = NSString(data: data, encoding: NSUTF8StringEncoding) else { return }
                let mailingListMessagesOpt: [MailingListMessage?] = MailingListParser(string: listString as String)
                    .emails
                    .map { return MailingListMessageParser(string: $0) }
                    .map { return MailingListMessageParserAdapter(mailingListMessageParser: $0) }
                    .map { $0.mailingListMessage }
                    .filter { $0 != nil }
                
                // Swift compiler fucked up for some reason
                // mailingListMessagesOpt must have the nils filtered
                let mailingListMessages: [MailingListMessage] = mailingListMessagesOpt.map({ (msg) -> MailingListMessage in
                    return msg!
                })
                
                let emailFormatter = EmailFormatter()
                
                let emails: [Email] = mailingListMessages
                    .map { message in
                        let email = Email()
                        email.messageID = message.headers.messageID
                        email.from = message.headers.from
                        
                        if let date = emailFormatter.dateStringToDate(message.headers.date) {
                            email.date = date
                        }
                        
                        email.subject = message.headers.subject
                        email.mailingList = mailingList.rawValue.identifier
                        email.content = message.content
                        return email
                }
                
                var messageIDToEmail: [String: Email] = [String: Email]()
                
                // Index by ID
                for email in emails {
                    messageIDToEmail[email.messageID] = email
                }
                
                // Add `inReplyTo` and `references`
                for mailingListMessage in mailingListMessages {
                    if let email = messageIDToEmail[mailingListMessage.headers.messageID] {
                        if let inReplyTo = mailingListMessage.headers.inReplyTo {
                            let parent = messageIDToEmail[inReplyTo]
                            email.inReplyTo = parent
                        }
                        
                        for reference in mailingListMessage.headers.references {
                            if let refEmail = messageIDToEmail[reference] {
                                email.references.append(refEmail)
                            }
                        }
                    }
                }
                
                // Now build our threads
                // Build Parent -> [Children] mapping
                
                for child in emails {
                    if let parent = child.inReplyTo {
                        parent.children.append(child)
                    }
                }
                
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(emails, update: true)
                    }
                } catch let e {
                    print("Realm related error \(e)")
                }

                store.dispatch(SetMailingListIsRefreshing(mailingList: mailingList, isRefreshing: false))
            })
        }
        
        func doNetworkRequest() -> Action? {
            let session = NSURLSession(configuration: .defaultSessionConfiguration())
            let URL = NSURL(string: "https://lists.swift.org/pipermail/\(mailingList.rawValue.identifier)/\(period.identifier).txt.gz")!
            let request = NSURLRequest(URL: URL)
            
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                if let compressedData = data,
                    uncompressedData = compressedData.gunzippedData() {
                        dispatchActionForUncompressedData(uncompressedData)
                } else {
                    store.dispatch(SetMailingListIsRefreshing(mailingList: mailingList, isRefreshing: false))
                }
            }
            
            task.resume()
            return nil
        }
        
        return doNetworkRequest()
    }
}

//func RequestSwiftEvolution(period: ListPeriod, useCache: Bool = true) -> ((_: AppState, _: Store<AppState>) -> Action?) {
//    return { _, _ in
//        func filePathForPeriod(period: ListPeriod) -> String? {
//            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//            guard let documentsDirectory = paths.first else { return nil }
//            let file = (documentsDirectory as NSString).stringByAppendingPathComponent(period.fileName)
//            return file
//        }
//        
//        func dispatchActionForUncompressedData(data: NSData) {
//            guard let listString = NSString(data: data, encoding: NSUTF8StringEncoding) else { return }
//            let mailingListMessagesOpt: [MailingListMessage?] = MailingListParser(string: listString as String)
//                .emails
//                .map { return MailingListMessageParser(string: $0) }
//                .map { return MailingListMessageParserAdapter(mailingListMessageParser: $0) }
//                .map { $0.mailingListMessage }
//                .filter { $0 != nil }
//
//            // Swift compiler fucked up for some reason
//            // mailingListMessagesOpt must have the nils filtered
//            let mailingListMessages: [MailingListMessage] = mailingListMessagesOpt.map({ (msg) -> MailingListMessage in
//                return msg!
//            })
//            
//            let emails: [Email] = mailingListMessages
//                .map { message in
//                    let email = Email()
//                    email.messageID = message.headers.messageID
//                    email.from = message.headers.from
//                    email.date = message.headers.date
//                    email.subject = message.headers.subject
//                    email.mailingList = "swift-evolution"
//                    email.content = message.content
//                    return email
//                }
//            
//            var messageIDToEmail: [String: Email] = [String: Email]()
//            
//            // Index by ID
//            for email in emails {
//                messageIDToEmail[email.messageID] = email
//            }
//            
//            // Add `inReplyTo` and `references`
//            for mailingListMessage in mailingListMessages {
//                if let email = messageIDToEmail[mailingListMessage.headers.messageID] {
//                    if let inReplyTo = mailingListMessage.headers.inReplyTo {
//                        let parent = messageIDToEmail[inReplyTo]
//                        email.inReplyTo = parent
//                    }
//                    
//                    for reference in mailingListMessage.headers.references {
//                        if let refEmail = messageIDToEmail[reference] {
//                            email.references.append(refEmail)
//                        }
//                    }
//                }
//            }
//            
//            // Now build our threads
//            // Build Parent -> [Children] mapping
//            var parentToChildren: [Email: [Email]] = [Email: [Email]]()
//            
//            for child in emails {
//                if let parent = child.inReplyTo {
//                    if parentToChildren[parent] == nil {
//                        parentToChildren[parent] = []
//                    }
//                    
//                    parentToChildren[parent]?.append(child)
//                }
//            }
//            
//            func threadForEmail(rootEmail: Email) -> EmailThread {
//                let thread = EmailThread()
//                thread.rootEmailID = rootEmail.messageID
//                thread.children.appendContentsOf(parentToChildren[rootEmail] ?? [])
//                return thread
//            }
//            
//            let threads = emails.map(threadForEmail)
//            
//            let realm = try! Realm()
//            
//            try! realm.write {
//                realm.add(emails, update: true)
//                realm.add(threads, update: true)
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                mainStore.dispatch(SetEmailList(contents: emails))
//                mainStore.dispatch(SetMailingListIsRefreshing(mailingList: .SwiftEvolution, isRefreshing: false))
//            })
//        }
//        
//        func doNetworkRequest() -> Action? {
//            let session = NSURLSession(configuration: .defaultSessionConfiguration())
//            let URL = NSURL(string: "https://lists.swift.org/pipermail/swift-evolution/\(period.identifier).txt.gz")!
//            let request = NSURLRequest(URL: URL)
//            
//            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
//                if let compressedData = data,
//                    uncompressedData = compressedData.gunzippedData(),
//                    file = filePathForPeriod(period) {
//                        uncompressedData.writeToFile(file, atomically: true)
//                        
//                        dispatchActionForUncompressedData(uncompressedData)
//                }
//            }
//            
//            task.resume()
//            return nil
//        }
//        
//        if useCache {
//            // Load from local file, otherwise get the result from the network.
//            guard let file = filePathForPeriod(period), data = NSData(contentsOfFile: file) else {
//                return doNetworkRequest()
//            }
//            
//            dispatchActionForUncompressedData(data)
//            return nil
//        }
//        
//        return doNetworkRequest()
//    }
//}
