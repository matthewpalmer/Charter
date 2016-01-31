//
//  AppReducer.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation
import ReSwift

struct AppReducer: Reducer {
    typealias ReducerStateType = AppState
    
    func handleAction(action: Action, var state: AppState?) -> AppState {
        if action is MoveTo {
            let move = action as! MoveTo
            state?.nextRoute = move.route
        }
        
        if action is NextRouteAcknowledged {
            if let route = state?.nextRoute {
                state?.routeHistory.append(route)
            }
            
            state?.nextRoute = nil
        }
        
        if action is SetEmailList {
            state?.emailList = (action as! SetEmailList).contents
        }
        
        if action is SetRootEmailList {
            state?.rootEmailList = (action as! SetRootEmailList).contents
        }
        
        return state ?? AppState()
    }
}
