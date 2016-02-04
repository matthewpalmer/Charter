//
//  AppState.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation
import ReSwift

enum Route {
    case MailingLists
    case Threads
    case ThreadDetail
}

struct AppState: StateType {
    var emailList: [Email] = []
    
    var selectedMailingList: MailingList? = nil
    var selectedThreadWithRootMessageID: String? = nil
    
    var mailingListIsRefreshing: [MailingList: Bool] = [
        MailingList.SwiftEvolution: false,
        MailingList.SwiftUsers: false
    ]
    
    var nextRoute: Route? = nil
    /// Earliest to newest - 1
    var routeHistory: [Route] = []
}
