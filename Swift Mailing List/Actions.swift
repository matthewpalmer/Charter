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
                .map { return Email(headers: $0.headers, content: $0.content, mailingList: .SwiftEvolution) }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                mainStore.dispatch(SetEmailList(contents: emails))
                mainStore.dispatch(SetMailingListIsRefreshing(mailingList: .SwiftEvolution, isRefreshing: false))
            })
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
