//
//  AppState.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation
import ReSwift
import RealmSwift

enum Route {
    case MailingLists
    case Threads
    case ThreadDetail
}

struct AppState: StateType {
    var emailList: Results<(Email)>? = nil
    var emailThread: [(Int, Email)]? = nil
    
    var selectedMailingList: MailingList? = nil
//    var selectedThreadWithRootMessageID: String? = nil
    
    var mailingListIsRefreshing: [MailingList: Bool] = [
        MailingList.SwiftEvolution: false,
        MailingList.SwiftUsers: false,
        MailingList.SwiftDev: false
    ]
    
    var nextRoute: Route? = nil
    /// Earliest to newest - 1
    var routeHistory: [Route] = []
}
