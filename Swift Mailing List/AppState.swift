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
    case Threads
    case ThreadDetail
}

struct AppState: StateType {
    var rootEmailList: [Email] = []
    var emailList: [Email] = []
    
    var nextRoute: Route? = nil
    /// Earliest to newest - 1
    var routeHistory: [Route] = []
}
